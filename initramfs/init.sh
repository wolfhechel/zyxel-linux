#!/bin/sh

mount -t proc none /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

echo "Booted!"

/bin/setsid /bin/cttyhack /bin/sh
exec /bin/sh