#!/usr/bin/env python

from __future__ import print_function
from builtins import input
import shutil
import argparse
import subprocess
import pwd
import re
import os
import sys

parser = argparse.ArgumentParser(description='Process additional arguments')
parser.add_argument('-t', '--type', help="Type of backup to be performed: full/standard")
parser.add_argument('-a', '--action', help="Action to be performed: backup/restore")
parser.add_argument('-l', '--location', help="Location of backup drive without trailing slash; E.g. /Volumes/BACKUP")
parser.add_argument('-u', '--username', help="Username of account to be backed up")
args = parser.parse_args()

standardCopy = ['Desktop', 'Documents', 'Downloads', 'Pictures', 'Music', 'Movies']

def prompt():
	print("What type of backup should be performed? (standard/full)")
	backupType = input()
	assert isinstance(backupType, str)

	print("Do you want to backup or restore? (backup/restore)")
	backupAction = input()
	assert isinstance(backupAction, str)

	print("Where is your backup drive? E.g. /Volumes/Untitled")
	backupDrive = input()
	assert isinstance(backupDrive, str)

	print("Which user would you like to backup?")
	backupUser = input()
	assert isinstance(backupUser, str)

	return(backupType, backupAction, backupDrive, backupUser)

def environmentValidation():
	errorEncountered = False

	if args.type != 'standard' and args.type != 'full' and args.type != None:
		print('ERROR: Type of backup not recognized', file=sys.stderr)
		print('Please use either "standard" or "full" with "-t/--type"', file=sys.stderr)
		errorEncountered = True

	if args.action != 'backup' and args.action != 'restore' and args.action != 'direct':
		print('ERROR: Backup/restore action not recognized', file=sys.stderr)
		print('Please use with "backup", "restore" or "direct" with "-a/--action"', file=sys.stderr)
		errorEncountered = True

	if not os.path.exists(args.location):
		print("ERROR: Given '--location' does not exist", file=sys.stderr)
		print("Please check the backup drive/location and run again", file=sys.stderr)
		errorEncountered = True
	
	if args.action == 'backup' or args.action == 'direct':
		try:
			pwd.getpwnam(args.username)
		except KeyError:
			print("ERROR: User given is not recognized, please check the username and try again", file=sys.stderr)
			errorEncountered = True

	if not os.geteuid() == 0:
		print("ERROR: This script must be run with root privileges in order to move user home folder, please run with sudo and try again", file=sys.stderr)
		errorEncountered = True 

	try:
		temp = open('/Library/Application Support/com.apple.TCC/tcc.db')
		temp.close()
	except:
		print('ERROR: Terminal requires full-disk access in order to perform this script, please give Terminal full-disk access in Security and Privacy and try again', file=sys.stderr)
		errorEncountered = True
		
	if errorEncountered:
		parser.print_help(sys.stderr)
		exit(1)

def backup(location, type, username):
	userPath = os.path.expanduser('~' + username)
	backupPath = location + '/'

	if os.path.exists(backupPath + username):
		print("WARNING: User already exists at " + backupPath + username)
		print("Are you sure you wish to overwrite the existing folder (y/n)")
		option = input()
		assert isinstance(option, str)
		if not re.search(r'[yY]', option):
			print('INFO: Not overwriting existing user folder, exiting...')
			exit(1)
		else:
			shutil.rmtree(backupPath + username, ignore_errors=True)

	if type == "full":
		subprocess.call(['rsync', '-aEh', '--progress', userPath, backupPath])
	else:
		os.mkdir(backupPath + username)
		for folder in standardCopy:
			subprocess.call(['rsync', '-aEh', '--progress', userPath + '/' + folder, backupPath + username + '/'])
	
	f = open(backupPath + username + '/' + username + '-path', 'w')
	f.write(userPath)
	f.close()

def restore(location, type, username):
	userID = pwd.getpwnam(args.username).pw_uid
	backupPath = location + '/' + username

	if os.path.isfile(backupPath + '/' + username + '-path'):
		f = open(backupPath + '/' + username + '-path', 'r')
		userPath = os.path.dirname(f.read())
		restorePath = userPath + '/'
		f.close()
	else:
		restorePath = '/Users/'

	if os.path.exists(restorePath + username):
		print("WARNING: User already exists at " + restorePath + username)
		print("Are you sure you wish to overwrite the existing folder (y/n)")
		option = input()
		assert isinstance(option, str)
		if not re.search(r'[yY]', option):
			print('INFO: Not overwriting existing user folder, exiting...')
			exit(1)
		else:
			if type == "full":
				shutil.rmtree(restorePath + username)
			else:
				for folder in standardCopy:
					shutil.rmtree(restorePath + username + '/' + folder)
	
	if type == "full":
		subprocess.call(['rsync', '-aEh', '--progress', backupPath, restorePath])
	else:
		for folder in standardCopy:
			subprocess.call(['rsync', '-aEh', '--progress', backupPath + '/' + folder, restorePath + username + '/'])
	
	os.chown(restorePath + username, userID, -1)
	
def main():
	if not len(sys.argv) > 1:
		print("No arguments given, using prompt instead")
		results = prompt()
		args.type = results[0]
		args.action = results[1]
		args.location = results[2]
		args.username = results[3]

	environmentValidation()

	if args.type == None:
		args.type = "standard"
	if args.action == "backup":
		backup(args.location, args.type, args.username)
	else:
		restore(args.location, args.type, args.username)

if __name__ == "__main__":
	main()

