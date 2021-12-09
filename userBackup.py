#!/usr/bin/env python3

import argparse
import subprocess
import re
import os
import sys

parser = argparse.ArgumentParser(description='Process additional arguments')
parser.add_argument('-t', '--type')
parser.add_argument('-a', '--action', required=True)
parser.add_argument('-l', '--location', required=True)
parser.add_argument('-u', '--username', required=True)
args = parser.parse_args()

standardCopy = ['Desktop', 'Documents', 'Downloads', 'Pictures', 'Music', 'Movies']

def argumentValidation():
	if args.type != 'standard' and args.type != 'full':
		print('ERROR: Type of backup not recognized')
		print('Please use either "standard" or "full" with "-t/--type"')
		parser.print_help(sys.stderr)

	if args.action != 'backup' and args.action != 'restore' and args.action != 'direct':
		print('ERROR: Backup/restore action not recognized')
		print('Please use with "backup", "restore" or "direct" with "-a/--action"')
		parser.print_help(sys.stderr)

def backup(location, type, username):
	backupPath = location + '/' + username

	if os.path.exist(backupPath):
		print("WARNING: User already exists at" + backupPath)
		print("Are you sure you wish to overwrite the existing folder (y/n)")
		option = input()
		if not re.search(r'[yY]', option):
			print('INFO: Not overwriting existing user folder, exiting...')
			exit(1)
	
	if type == "full":
		subprocess.call(['rsync', '-aeh', '--progress', '/Users/' + username, backupPath])
	else:
		for folder in standardCopy:
			subprocess.call(['rsync', '-aeh', '--progress', '/Users/' + username, backupPath + '/' + folder])

def restore(location, type, username):
	if os.path.exist('/Users/' + username):
		print("WARNING: User already exists at /Users/" + username)
		print("Are you sure you wish to overwrite the existing folder (y/n)")
		option = input()
		if not re.search(r'[yY]', option):
			print('INFO: Not overwriting existing user folder, exiting...')
			exit(1)
	
	if type == "full":
		subprocess.call(['rsync', '-aeh', '--progress', location, '/Users/' + username])
	else:
		for folder in standardCopy:
			subprocess.call(['rsync', '-aeh', '--progress', location + '/' + folder, '/Users/' + username + '/' + folder])
	
def main():
	argumentValidation()

	if args.type == None:
		type = "standard"
	if args.action == "backup":
		backup(args.location, type, args.username)
	else:
		restore(args.location, type, args.username)

if __name__ == "__main__":
	main()

