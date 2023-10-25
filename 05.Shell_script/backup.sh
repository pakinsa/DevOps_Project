#!/usr/bin/bash

################
#Author: Paul Akinsande
#Date: 21/10/2023
#Purpose: Learning how to backup in bash scripting
#Assignment: Copying files from source directory recurively into the backup directory with timestamps
################

# Define source and backup directory

mkdir sourcedir && touch sourcedir/1a.txt sourcedir/1b.txt sourcedir/1c.txt

mkdir backeddir


# Get the absolute path to the source and backup directories
sourcedir="$(readlink -f "$(dirname -- "${BASH_SOURCE[0]}")")"
echo "$sourcedir"
ls sourcedir

backeddir="$(readlink -f "$(dirname -- "${BASH_SOURCE[0]}")")"
echo "$backeddir"


# Initialise a timestamp method and save the timestamp file in the backup directory
timestamp=$(date +"%Y%m%d%H%M%S")     # You can as welluse this : $(date +"%Y%m%d%H%M%S")
echo "First completed backup: "$timestamp>backeddir/timestamp.txt   # Save timestamp.txt to the backup directory


# copy all files from sourcedir to backupwithtime
cp -r "sourcedir"/* "backeddir/"

# print message
ls backeddir
echo "Backup Completed to backeddir on $timestamp"


