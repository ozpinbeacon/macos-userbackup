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

sudo rsync -aEh --progress /Users/${users[$username]} /Volumes/${locations[$backup]}/Users/

echo "All done!"
