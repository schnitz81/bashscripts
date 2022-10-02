#!/bin/bash

#######################################################################
# This script compresses a selected folder to a selected destination  #
# with time stamp.                                                    #
# Two input parameters are expected:                                  #
# ./tarfolder (folder to backup) (destination path)                   #
#######################################################################

# Get input parameters
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Exactly 2 input parameters needed."
    echo "./tarfolder (folder to backup) (destination path)"
    exit 1
fi

# Folder to compress:
folder_to_compress=$1

# Name of file to create
tarballname=$(echo $1 | rev | cut -d '/' -f 1 | rev)

# Destination folder:
destination_folder=$(echo "$2" | sed 's:/*$::')

# Check if destination folder exists:
if [ ! -d $destination_folder ]; then
    echo "Destination folder $destination_folder/$tarball_location does not exist."; exit 0
# Check if source folder exists:
elif [ ! -d $folder_to_compress ]; then
    echo "Source folder $folder_to_compress does not exist."; exit 0
else
    echo "Tarball location and folder to backup exist. Starting compression of folder..."
fi

# Get current date:
now=$(date +"%Y_%m_%d__%H_%M")

# Compress folder:
TARCMD=`tar -jcvf "$destination_folder"/"$tarballname"_"$now".tar.bz2 -C "$folder_to_compress" .`
if [ $? != 0 ]; then
{
    echo "Compressing error."
    echo $TARCMD
    exit 1
}
else
    echo "Compressed tarball successfully created:"
    echo "$destination_folder/$tarballname_$now.tar.bz2"
fi

