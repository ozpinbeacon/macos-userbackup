#!/bin/bash
###############################################
# User restore beta.sh
#
# Uses rsync to restore a previously created
# archive of a users home folder to switch to
# a new computer
#
# Made by Liam Matthews - 14-02-18
###############################################
# Determining location to retrieve backup data

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

###############################################
# Determining which user to restore from backup

echo Pick a user to restore

cd /
cd Volumes
cd "${locations[$backup]}"
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

echo Please type the name of the user you wish to restore.
read username

echo Would you like to do a minimal backup or a full backup?
echo 1. Minimal Backup
echo 2. Full Backup
read choice

echo I am now going to restore "${users[$username]}"

read -n 1 -s -r -p "Press any key to continue"

###############################################
# Creating a mobile account for the user

sleep 2s
sudo /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n "${users[$username]}"
sleep 2s

###############################################
# Restoring the data

if [ $choice == "1" ]
then
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Desktop /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Documents /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Downloads /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Movies /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Pictures /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Music /Users/"${users[$username]}"/
elif [ $choice == "2" ]
then
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}" /Users/
else
    echo "Choice not recgonized, please run script again."
    exit 1
fi

echo Finished restoring user, now restoring ownership.

###############################################
# Changing of ownership to allow for use

sudo chown -R "${users[$username]}":admin /Users/"${users[$username]}"

###############################################
# Removing configuration profile

sudo profiles remove -identifier=B48A6E5B-BAA3-4E30-97A2-7B83AA708A8D

echo Restoration complete!

exit 0
