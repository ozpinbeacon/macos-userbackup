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

echo Pick location of backup data

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

echo "Select location number"
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

echo Would you like to do a minimal restoration or a full restoration?
echo 1. Minimal Restore
echo 2. Full Restore
read backupType

echo Create mobile account now?
echo Y/N?
read accountCreation

###############################################
# Creating a mobile account for the user

if [ $accountCreation == "y" ] || [ $accountCreation == "Y" ]
then
  sleep 2s
  sudo /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n "${users[$username]}"
  sleep 2s
elif [ $accountCreation == "n" ] || [ $accountCreation == "N" ]
then
  echo Account not created
else
  echo Choice not recognized, please run script again
  exit 1
fi

##############################################

echo I am now going to restore "${users[$username]}"

read -n 1 -s -r -p "Press any key to continue"
echo ""

###############################################
# Restoring the data

if [ $backupType == "1" ]
then
  if [ ! -d "/Volumes/'${locations[$backup]}'/Users/'${users[$username]}'/Library" ]
  then
      echo ""
      echo "This backup was made using the full backup option and you have selected to restore using the minimal restore option. This will only copy files and will not copy any preferences or other Library files."
      echo "Would you like to proceed?"
      echo Y/N?
      read minimalUsingFull
      if [ $minimalUsingFull == "y" ] || [ $minimalUsingFull == "Y" ]
      then
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Desktop /Users/"${users[$username]}"/
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Documents /Users/"${users[$username]}"/
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Downloads /Users/"${users[$username]}"/
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Movies /Users/"${users[$username]}"/
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Pictures /Users/"${users[$username]}"/
        sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Music /Users/"${users[$username]}"/
      elif [ $minimalUsingFull == "n" ] || [ $minimalUsingFull == "N" ]
      then
        echo "Backup was not completed. Please run script again."
        exit 0
      else
        echo "Choice not recognized, please run the script again."
        exit 1
      fi
  else
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Desktop /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Documents /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Downloads /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Movies /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Pictures /Users/"${users[$username]}"/
    sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}"/Music /Users/"${users[$username]}"/
  fi
elif [ $backupType == "2" ]
then
  if [ ! -d "/Volumes/'${locations[$backup]}'/Users/'${users[$username]}'/Library" ]
  then
      echo "This option requires the use of the backup profile, please ensure this is installed."
      read -n 1 -s -r -p "Press any key to continue"
      echo ""
      sudo rsync -aEh --progress /Volumes/"${locations[$backup]}"/Users/"${users[$username]}" /Users/
  else
      echo "This user was backed up using the minimal option and thus cannot be restored using the full option. Please re run the script and select minimal"
      exit 1
  fi
else
  echo "Choice not recognized, please rerun the script and try again"
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
