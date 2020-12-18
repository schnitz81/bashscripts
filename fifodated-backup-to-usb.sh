#!/bin/bash

#######################################################################
# This script tries to mount the latest added device and create a     #
# a tarball with timestamp in the file name.                          #
# The destination folder is checked for older tarballs with similar   #
# names and deletes the oldest if the chosen number of archived       #
# tarballs is exceeded. Suitable for cronjob triggered backup of a    #
# specific folder.                                                    #
#######################################################################

# Device path:
device="/dev/`dmesg | grep -o "sd[a-k][1]" | tail -n 1`"

# Mount point:
mountpoint="/mnt/usbstick"

# Folder to backup:
folder_to_backup="/home/tux/docs"

# Tarball name (date and time will be added automatically)
tarball_name="backup_archive"

# Maximum nr of backup files:
max_nr_of_backup_files=5


# Check if target device is inserted:
if [ ! -e $device ]; then
    echo "The device $device does not exist."; exit 1
# Check if mount point folder exists:
elif [ ! -d $mountpoint  ]; then
    echo "Mount point $mountpoint does not exist."; exit 1
elif [ ! -d $folder_to_backup ]; then
    echo "The folder $folder_to_backup does not exist."; exit 1
# Everything ok, run backup routine:
else
    echo "Target partition, mount point and source folder exist."
    echo "Mounting target partition..."
fi

# Mount target partition:  
MOUNTCMD=`mount -t vfat "$device" "$mountpoint" 2>&1`
if [ $? != 0 ]; then
{
    echo "Mounting error."
    echo $MOUNTCMD
    exit 1
} 
else
    echo "Device mounted."
fi

# Get current date:
now=$(date +"%Y_%m_%d__%H_%M")

# Tar folder:
echo "Compressing tarball..."
TARCMD=`tar -jcvf "$mountpoint"/"$tarball_name"_"$now".tar.bz2 -C "$folder_to_backup" .`
if [ $? != 0 ]; then
{
    echo "Compressing error."  
    echo $TARCMD
} 
else
    echo "Backup tarball succesfully created."
fi

# Check if maximum nr of backup files is exceeded. Delete oldest if exceeded.
echo "Counting tarballs..."
if [ `ls -l "$mountpoint"/"$tarball_name"_*.tar.bz2 | wc -l` -gt $max_nr_of_backup_files ]; then
    echo "Maximum nr of backup files exceeded. Deleting oldest..."
    rm -v `ls -tr1 "$mountpoint"/"$tarball_name"_*.tar.bz2 | head -1`
else
    echo "No. of backup files OK."
fi

# Unmount mountpoint
UMOUNTCMD=`umount "$mountpoint" 2>&1`
if [ $? != 0 ]; then
{
    echo "Unmounting error."
    echo $UMOUNTCMD
    exit 1
} 
else
    echo "Unmount successful. Exiting..."
fi
