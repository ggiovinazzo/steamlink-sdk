#!/bin/sh
#

MOUNT_DISK=/mnt/disk
ERROR_MOUNTING_PARTITION_FILE=/tmp/error_mounting_partition.txt

# Check if we have a Mass Media device on USB
mass_media_class=$(find /sys/devices/soc.0/f7ee0000.usb/ -name bInterfaceClass | xargs grep 08)
if [ -n "$mass_media_class" ]; then
  # Additional wait for the disk device to be created
  sleep 2
  mkdir -p ${MOUNT_DISK}
  # Iterate over all partitions
  for device in $(blkid | awk -F ':' '{ print $1 }'); do
     case $device in
         /dev/loop*)
	  ;;
         /dev/block/loop*)
          ;;
        *)
          echo "Found device $device" > /dev/console

	  mount_status=$(grep "$MOUNT_DISK" /proc/mounts)
	  if [ -z "$mount_status" ]; then
	    mount $device ${MOUNT_DISK}
            ret=$?
            if [ $ret -ne 0 ]; then
              # Pass device name to application, it can indidate it to user
              echo "$device" >> $ERROR_MOUNTING_PARTITION_FILE
            fi
          fi
      esac
  done
  break
fi
