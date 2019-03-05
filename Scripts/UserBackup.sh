#!/bin/bash
###############################################
# User Backup.sh
#
# Uses rsync to create an archive of a users
# home folder to switch to a new computer
#
# Added using Atom + GitHub
#
# Made by Liam Matthews - 14-02-18
###############################################
# Determining location to store backup data

echo Pick a backup location

cd /
cd Volumes

declare -a locations
indexNumber=1
for i in *
do
locations[$indexNumber]=$i
indexNumber=$((indexNumber+1))
done
for i in "${!locations[@]}"
do
echo "$i - ${locations[$i]}"
done

echo "Please type the location name below"
read backup

if [ ! -d "/Volumes/${locations[$backup]}/Users/" ]
then
    mkdir /Volumes/${locations[$backup]}/Users/
    echo "Creating Users folder in backup drive"
fi

###############################################
# Determining type of backup

echo Would you like to do a minimal backup or a full backup?
echo 1. Minimal Backup
echo 2. Full Backup
read backupType

###############################################
# Determining Users to Backup

echo "Pick a user to backup"

cd /
cd Users

declare -a users
indexNumber=1
for i in *
do
users[$indexNumber]=$i
indexNumber=$((indexNumber+1))
done
for i in "${!users[@]}"
do
echo "$i - ${users[$i]}"
done

echo Please type the name of the user you wish to backup.
read username

echo "I am now going to backup ${users[$username]}"

read -n 1 -s -r -p "Press any key to continue"

##############################################
# Backing up of data to respective areas. Copying extensive attributes with data so as to avoid any '~$' documents

if [ $backupType == "1" ]
then
    echo "Performing minimal backup"
    echo ""
    sudo rsync -aEh --progress /Users/${users[$username]}/Desktop /Volumes/${locations[$backup]}/Users/${users[$username]}/
    sudo rsync -aEh --progress /Users/${users[$username]}/Documents /Volumes/${locations[$backup]}/Users/${users[$username]}/
    sudo rsync -aEh --progress /Users/${users[$username]}/Downloads /Volumes/${locations[$backup]}/Users/${users[$username]}/
    sudo rsync -aEh --progress /Users/${users[$username]}/Pictures /Volumes/${locations[$backup]}/Users/${users[$username]}/
    sudo rsync -aEh --progress /Users/${users[$username]}/Music /Volumes/${locations[$backup]}/Users/${users[$username]}/
    sudo rsync -aEh --progress /Users/${users[$username]}/Movies /Volumes/${locations[$backup]}/Users/${users[$username]}/
elif [ $backupType == "2" ]
then
    echo "Performing full backup"
    echo ""
    sudo rsync -aEh --progress /Users/${users[$username]} /Volumes/$locations[$backup]}/Users/
else
    echo "Choice not recognized. Please run script again"
    exit 1
fi

echo "Backup completed"

echo "All done!"
