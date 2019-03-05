#!/bin/bash

echo "Would you like to backup data or restore?"
echo "1. Backup"
echo "2. Restore"
read backupOrRestore

if [ $backupOrRestore == "1" ]
then
	sudo ./UserBackup.sh
	exit 0
elif [ $backupOrRestore == "2" ]
then
	sudo ./UserRestore.sh
	exit 0
else
	echo "Choice not recognized. Please run script again."
	exit 1
fi
