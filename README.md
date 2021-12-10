# macOS-userbackup

Backup of user data through rsync.

To use run userBackup.py

usage: userBackup.py [-h] [-t TYPE] -a ACTION -l LOCATION -u USERNAME

-h | Prints help message and exits
-t | Type of backup to be performed; Either standard (copies Desktop, Documents, Downloads, Music, Pictures, and Movies) or full which copies the entire user home    folder
-a | Backup or Restore data, direct functionality to come for use with Target Disk Mode
-l | Location of backup drive. E.g. If the backup drive is Backup use /Volumes/Backup (no trailing slash)
-u | Username, self explanatory
