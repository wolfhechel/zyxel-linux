#!/usr/bin/env python

import time
import os
import sys
import logging
import copy
import threading
import termios

import serial
from serial.tools import list_ports
import xmodem
from progressbar import ProgressBar, ETA, Bar, FileTransferSpeed, DataSize, Percentage



logging.basicConfig(level=logging.FATAL)


class Terminal(object):

    alive = False

    transmitter_thread = None

    exit_key = serial.to_bytes([0x04])   # GS/CTRL+D

    newline = serial.to_bytes([13, 10])

    stdin_fd = sys.stdin.fileno()

    original_tc_attrs = termios.tcgetattr(stdin_fd)

    def __init__(self, connection):
        self.serial = connection

    def _start_reader(self):
        self._reader_alive = True
        # start serial->console thread
        self.receiver_thread = threading.Thread(target=self.reader)
        self.receiver_thread.setDaemon(True)
        self.receiver_thread.start()

    def _configure_console(self):
        new = copy.copy(self.original_tc_attrs)

        new[3] = new[3] & ~termios.ICANON & ~termios.ECHO & ~termios.ISIG
        new[6][termios.VMIN] = 1
        new[6][termios.VTIME] = 0

        termios.tcsetattr(self.stdin_fd, termios.TCSANOW, new)

    def _restore_terminal(self):
        termios.tcsetattr(self.stdin_fd, termios.TCSAFLUSH, self.original_tc_attrs)

    def _stop_reader(self):
        self._reader_alive = False
        self.receiver_thread.join()

    def start(self):
        self._configure_console()
        sys.exitfunc = self._restore_terminal

        self.alive = True
        self._start_reader()
        self.transmitter_thread = threading.Thread(target=self.writer)
        self.transmitter_thread.setDaemon(True)
        self.transmitter_thread.start()

    def stop(self):
        self.alive = False

    def join(self, transmit_only=False):
        self.transmitter_thread.join()

        if not transmit_only:
            self.receiver_thread.join()

    def reader(self):
        try:
            while self.alive and self._reader_alive:
                data = self.serial.read(1)

                # direct output, just have to care about newline setting
                sys.stdout.write(data)
                sys.stdout.flush()
        except serial.SerialException:
            self.alive = False
            raise

    def writer(self):
        try:
            while self.alive:
                try:
                    c = os.read(self.stdin_fd, 1)
                except KeyboardInterrupt:
                    c = serial.to_bytes([3])

                if c == self.exit_key:
                    self.stop()
                    break
                else:
                    self.serial.write(
                        self.newline if c == '\n' else c
                    )
        except:
            self.alive = False
            raise


class ZyxelSerial(serial.Serial):

    LINE_FEED = b'\r\n'

    RESPONSE_OK = b'OK'

    RESPONSE_ERROR = b'ERROR'

    RESPONSES = (RESPONSE_OK, RESPONSE_ERROR)

    session_log_file = None

    def __init__(self, *args, **kwargs):
        super(ZyxelSerial, self).__init__(*args, **kwargs)

        self.session_log_file = open('last_session', 'w')

    def read(self, size=1):
        data = super(ZyxelSerial, self).read(size)

        self.session_log_file.write(data)

        return data

    def send_command(self, data, linefeed=True):
        if linefeed:
            data += '\r\n'

        ret = self.write(data)

        self.read(len(data))

        return ret

    def command(self, data, linefeed=True):
        self.send_command(data, linefeed)

        return self.read_response()

    def read_response(self, prebuff=None):
        data = ''

        if prebuff:
            data += prebuff

        response = None
        while response is None:
            data += self.read(1)

            if data.endswith(self.RESPONSE_OK + self.LINE_FEED):
                response = True
                data = data[:-(len(self.RESPONSE_OK) + 2)]
            elif data.endswith(self.RESPONSE_ERROR + self.LINE_FEED):
                response = False
                data = data[:-(len(self.RESPONSE_ERROR) + 2)]

        return response, data.strip()


def generate_password(seed):
    ror = lambda v, p: (v >> p) | (v << (8 * 4 - p))

    a = seed[:6]
    e = int(a, 16)
    c = seed[-2:]
    d = int(c, 16) & 7
    b = e + 0x10F0A563L
    b = ror(b, d)
    password = b ^ e

    return ('%X' % password)[-8:]


def main(connection, firmware, address, enter_terminal=True):
    connection.flush()

    sys.stdout.write('\033cWaiting for device boot...')

    def print_until_line(line):
        char_index = 0
        buff = ''
        skip_line = False

        while True:
            char = connection.read()

            if not skip_line and (char == line[char_index]):
                buff += char
                char_index += 1

                if buff == line:
                    break
            else:
                if char in ('\n', '\r'):
                    skip_line = False
                else:
                    skip_line = True

                if char_index > 0:
                    sys.stdout.write(buff)
                    buff = ''
                    char_index = 0

                sys.stdout.write(char)
                sys.stdout.flush()

    print_until_line('Press any key to enter debug mode within 3 seconds.\r\n')

    connection.send_command('')

    while connection.inWaiting():
        sys.stdout.write(connection.readline())

    # Increase baud rate

    ok, data = connection.command('ATBA5\r')

    if ok:
        sys.stdout.write(data + '\n')
        connection.setBaudrate(115200)
        time.sleep(0.5)

    # Get seed, generate password and enter privileged debug mode

    ok, seed = connection.command('ATSE')

    if ok:
        privileged_pass = generate_password(seed)

        ok, data = connection.command('ATEN1,%s' % privileged_pass)

        if ok:
            sys.stdout.write('Set BootExtension Debug Flag.\n')
        else:
            raise SystemExit('Failed to set BootExtension Debug Flag.')

    if firmware:
        # Upload code
        firmware_stat = os.fstat(firmware.fileno())

        connection.send_command(b'ATUP%x,%x' % (address, firmware_stat.st_size))

        print_until_line('C')

        def getc(size, timeout=1):
            return connection.read(size)

        def putc(data, timeout=1):
            connection.write(data)

        transfer = xmodem.XMODEM(getc, putc, mode='xmodem1k')

        packet_size = dict(
            xmodem=128,
            xmodem1k=1024,
        )[transfer.mode]

        retries = 16

        widgets = [Percentage(), ' ',
               Bar(marker='*', left='[', right=']'),
               ' ', ETA(), ' ', FileTransferSpeed()]

        pbar = ProgressBar(widgets=widgets, max_value=firmware_stat.st_size)

        def print_progress(sent_packets, success_count, error_count):
            pbar.update(min(sent_packets * packet_size, pbar.max_value))

        transfer.send(firmware, retry=retries, quiet=1, callback=print_progress)

        sys.stdout.write(''.join(connection.readlines(2)))

        # Execute code
        sys.stdout.write('Executing code at 0x%x...\n' % address)
        connection.send_command('ATGO%x' % address)

    if enter_terminal:
        sys.stdout.write('Entering terminal, exit with Ctrl+D.\n')

        terminal = Terminal(connection)

        terminal.start()

        try:
            terminal.join(True)
        except KeyboardInterrupt:
            pass

        terminal.join()

    sys.stdout.write('\nThis session has been saved to {}\n'.format(connection.session_log_file.name))



if __name__ == '__main__':
    import argparse

    argument_parser = argparse.ArgumentParser()

    serial_ports = list_ports.comports()

    if serial_ports:
        default_serial_port = serial_ports[0][0]
    else:
        argument_parser.error('No serial ports detected')
        default_serial_port = ''

    def serial_interface(value):
        valid_serial_interfaces = [s[0] for s in serial_ports]

        if value not in valid_serial_interfaces:
            raise argparse.ArgumentTypeError(
                'Invalid serial port {}\n\nValid ports are:\n{}'.format(
                    value,
                    '\n'.join(valid_serial_interfaces)
                )
            )

        return ZyxelSerial(value, 9600, timeout=1)

    argument_parser.add_argument('-l', '--load-address', default=0x94100000, type=lambda x: int(x, 16),
                                 help='Upload firmware to memory address')
    argument_parser.add_argument('-s', '--serial', type=serial_interface,
                                 default=default_serial_port, help='Serial port')
    argument_parser.add_argument('firmware', type=argparse.FileType('r'), nargs='?', default=None)

    namespace = argument_parser.parse_args()

    try:
        main(namespace.serial, namespace.firmware, namespace.load_address)
    finally:
        namespace.serial.close()
