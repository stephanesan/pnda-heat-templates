#!/bin/bash -v

# This script runs on all instances except the saltmaster
# It installs a salt minion and mounts the disks

set -ex

DISTRO=$(cat /etc/*-release|grep ^ID\=|awk -F\= {'print $2'}|sed s/\"//g)

if [ "x$DISTRO" == "xubuntu" ]; then
export DEBIAN_FRONTEND=noninteractive
apt-get -y install xfsprogs=3.1.9ubuntu2
elif [ "x$DISTRO" == "xrhel" ]; then
yum -y install xfsprogs-4.5.0-9.el7_3
fi

# Mount the disks
VOLUME_ID="$kafkalog_volume_id$"
VOLUME_DEVICE="/dev/disk/by-id/virtio-$(echo ${VOLUME_ID} | cut -c -20)"
echo VOLUME_DEVICE is $VOLUME_DEVICE
if [ -b $VOLUME_DEVICE ]; then
  echo VOLUME_DEVICE exists
  umount $VOLUME_DEVICE || echo 'not mounted'
  mkfs.xfs $VOLUME_DEVICE
  mkdir -p /var/kafka-logs
  cat >> /etc/fstab <<EOF
$VOLUME_DEVICE  /var/kafka-logs xfs defaults  0 0
EOF
else
  echo VOLUME_DEVICE does not exists
fi

cat /etc/fstab
mount -a
