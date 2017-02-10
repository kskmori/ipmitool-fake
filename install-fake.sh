#!/bin/sh

IPMITOOL=/usr/bin/ipmitool
FAKEPATH=/usr/share/ipmitool-fake/ipmitool-fake.sh
BACKUPPATH=/usr/share/ipmitool-fake/ipmitool.bin

if [ "$1" = "-i" ]; then
  if [ -x ${FAKEPATH} ] && file ${IPMITOOL} | grep -q ELF > /dev/null 2>&1 ; then
    mv ${IPMITOOL} ${BACKUPPATH}
    ln -s ${FAKEPATH} ${IPMITOOL}
    echo "Installed ipmitool-fake"
  else
    echo "ipmitool has been already replaced. did nothing."
  fi
elif [ "$1" = "-u" ]; then
  if [ -x ${BACKUPPATH} ] && file ${IPMITOOL} | grep "symbolic link" >/dev/null 2>&1 ; then
    rm ${IPMITOOL}
    mv ${BACKUPPATH} ${IPMITOOL}
    echo "Uninstalled ipmitool-fake"
  else
    echo "ipmitool-fake does not seem to be installed. did nothing."
  fi
else
  echo "usage: $0 [-i|-u]"
  exit 1
fi

exit 0
