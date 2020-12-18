#!/bin/bash

#######################################################################
# This script compresses a selected folder to a selected destination  #
# with time stamp.                                                    #
# The destination folder is checked for older tarballs with similar   #
# names and deletes the oldest if the chosen number of archived       #
# tarballs is exceeded. Suitable for cronjob triggered backup of a    #
# specific folder.                                                    #
#######################################################################


# Destination folder:
tarball_location="/home/tux"

# Folder to compress:
folder_to_compress="/home/tux/documents"

# Tarball name (date and time will be added automatically)
tarball_name="backup_archive"

# Maximum nr of tarballs:
max_no_of_tarballs=5


# Check if destination folder exists:
if [ ! -d $tarball_location ]; then
    echo "Destination folder $tarball_location does not exist."; exit 0
# Check if source folder exists:
elif [ ! -d $folder_to_compress ]; then
    echo "Source folder $folder_to_compress does not exist."; exit 0
else
    echo "Tarball location and folder to backup exist. Starting compression of folder..."	

# Get current date:
now=$(date +"%Y_%m_%d__%H_%M")

# Compress folder:
TARCMD=`tar -jcvf "$tarball_location"/"$tarball_name"_"$now".tar.bz2 -C "$folder_to_compress" .`
if [ $? != 0 ]; then
{
    echo "Compressing error."  
    echo $TARCMD
    exit 1
} 
else
    echo "Compressed tarball successfully created."
fi

# Check if maximum no of backup files is exceeded. Delete oldest if exceeded.
echo "Counting no. of tarballs..."
if [ `ls -l "$tarball_location"/"$tarball_name"_*.tar.bz2 | wc -l` -gt $max_no_of_tarballs ]; then
    echo "Maximum no. of backup files exceeded. Deleting oldest..."
    rm -v `ls -tr1 "$tarball_location"/"$tarball_name"_*.tar.bz2 | head -1`
else
    echo "No. of backupfiles OK"
fi

echo "Done."
fi

