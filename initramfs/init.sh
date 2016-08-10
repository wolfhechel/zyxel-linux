#!/bin/busybox sh

/bin/busybox echo "Testing"

/bin/busybox --install -s

echo "Testing"

mount -t procfs none /proc
mount -t sysfs none /sys

exec /bin/sh
