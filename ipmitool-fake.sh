#!/bin/bash
# Fake command of ipmitool for testing STONITH config on KVM environment
# Copyright (C) 2017 Keisuke MORI <keisuke.mori+ha@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Default value for config params
LOGFILE=/dev/null

### utilities
VIRSH=/usr/bin/virsh
hypervisor_uri="qemu:///session"
unset LANG
export LANG=C

error_exit() {
    echo "$*" 1>&2
    echo "$*" >>$LOGFILE
    exit 1
}

ha_log.sh() {
    echo "$1: $@" >>$LOGFILE
}

### main

echo "$(date) invoked: $0 $*" >>$LOGFILE

# check config
if [ -r /etc/ipmitool-fake.conf ]; then
    . /etc/ipmitool-fake.conf
else
    error_exit "/etc/ipmitool-fake.conf not found"
fi

OPT=$(getopt -o I:H:L:U:P:Ef: -n ipmitool-fake -- "$@")
if [ $? != 0 ]; then
    error_exit "getopt failed"
fi
eval set -- "$OPT"

while true; do
    case "$1" in
        -I)
            interface="$2"
            shift 2
            ;;
        -H)
            ipaddr="$2"
            shift 2
            ;;
        -L)
            priv="$2"
            shift 2
            ;;
        -U)
            user="$2"
            shift 2
            ;;
        -P)
            password="$2"
            shift 2
            ;;
        -E)
            password="${IPMI_PASSWORD}"
            shift
            ;;
        -f)
            password=$(cat "$2")
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            error_exit "unknown option '$1'"
            ;;
        esac
    done

## Auth check
if [ "$user" != "$USER" -o "$password" != "$PASSWORD" ]; then
    echo "Authentication failed user='$user', password='$password'" >>$LOGFILE
    error_exit "Authentication failed"
fi

## get vm name
if [ -z "$ipaddr" ]; then
    error_exit "missing -H option"
fi

domain_id=$(echo $VMCONFIG | sed "s/\s\s*/\n/g" | grep "$ipaddr:" | cut -d ':' -f 2)
if [ -z "$domain_id" ]; then
    error_exit "VM not found for IP address: $ipaddr"
fi

### action functions

### copied from external/libvirt in cluster-glue package
# start a domain
libvirt_start() {
    out=$($VIRSH -c $hypervisor_uri start $domain_id 2>&1)
    if [ $? -eq 0 ]
    then
        ha_log.sh notice "Domain $domain_id was started"
        return 0
    fi

    $VIRSH -c $hypervisor_uri dominfo $domain_id 2>&1 |
        egrep -q '^State:.*(running|idle)|already active'
    if [ $? -eq 0 ]
    then
        ha_log.sh notice "Domain $domain_id is already active"
        return 0
    fi

    ha_log.sh err "Failed to start domain $domain_id"
    ha_log.sh err "$out"
    return 1
}

# reboot a domain
# return
#   0: success
#   1: error
libvirt_reboot() {
    local rc out
    out=$($VIRSH -c $hypervisor_uri reboot $domain_id 2>&1)
    rc=$?
    if [ $rc -eq 0 ]
    then
        ha_log.sh notice "Domain $domain_id was rebooted"
        return 0
    fi
    ha_log.sh err "Failed to reboot domain $domain_id (exit code: $rc)"
    ha_log.sh err "$out"
    return 1
}

# stop a domain
# return
#   0: success
#   1: error
#   2: was already stopped
libvirt_stop() {
    out=$($VIRSH -c $hypervisor_uri destroy $domain_id 2>&1)
    if [ $? -eq 0 ]
    then
        ha_log.sh notice "Domain $domain_id was stopped"
        return 0
    fi

    $VIRSH -c $hypervisor_uri dominfo $domain_id 2>&1 |
        egrep -q '^State:.*shut off|not found|not running'
    if [ $? -eq 0 ]
    then
        ha_log.sh notice "Domain $domain_id is already stopped"
        return 2
    fi

    ha_log.sh err "Failed to stop domain $domain_id"
    ha_log.sh err "$out"
    return 1
}

# get status of stonith device (*NOT* of the domain).
# If we can retrieve some info from the hypervisor
# the stonith device is OK.
libvirt_status() {
    out=$($VIRSH -c $hypervisor_uri version 2>&1)
    if [ $? -eq 0 ]
    then
        return 0
    fi

    ha_log.sh err "Failed to get status for $hypervisor_uri"
    ha_log.sh err "$out"
    return 1
}

## do actions

case "$@" in
    "power reset")
        libvirt_reboot
        ;;
    "power off")
        libvirt_stop
        ;;
    "power on")
        libvirt_start
        ;;
    "power status")
        libvirt_status
        ;;
    *)
        error_exit "Invalid action: $@"
        ;;
esac
exit $?

