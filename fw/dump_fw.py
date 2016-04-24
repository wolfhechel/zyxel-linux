import struct


class ROMIO(object):

    _file_obj = None

    def __init__(self, file_obj):
        self._file_obj = file_obj

    @classmethod
    def from_filename(cls, filename):
        return cls(open(filename, 'rb'))