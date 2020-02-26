#!/usr/bin/env zsh -f
# Purpose: 	dropbox-ignore.sh: Set attribute to tell Dropbox to ignore a file or folder
# Source:  	https://help.dropbox.com/files-folders/restore-delete/ignored-files
#
# From:		Timothy J. Luoma
# Mail:		luomat at gmail dot com
# Date:		2020-02-26

NAME="$0:t:r"

if [[ -e "$HOME/.path" ]]
then
	source "$HOME/.path"
else
	PATH="$HOME/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"
fi

####################################################################################################
##
##	This section checks to see where the Dropbox folder actually resides.
##
##	It is _usually_ found at "$HOME/Dropbox/" but it can be changed.
##

	## I do not believe it is possible to change this location
	## so if this is not found, Dropbox is probably not installed on this computer
DOT_DROPBOX="$HOME/.dropbox"

if [[ ! -d "$DOT_DROPBOX" ]]
then
	echo "${NAME-$0}: '$DOT_DROPBOX' does not exist." >>/dev/stderr
	exit 2
fi

	## This JSON file has the information we want. Let's make sure it exists.
JSON="$DOT_DROPBOX/info.json"

if [[ ! -e "$JSON" ]]
then
	echo "${NAME-$0}: '$JSON' file not found." >>/dev/stderr
	exit 2
fi

	# If you have a 'work' or 'business' Dropbox and a 'personal' one,
	# this will only work on the 'personal' one
if (( $+commands[jq] ))
then
		## the 'jq' command can be installed via `brew install jq`
		## or downloaded from https://stedolan.github.io/jq/download/
		##
		## For more info: https://stedolan.github.io/jq/
	DROPBOX_PATH=$(jq -r '.personal.path' "$JSON")
else
		## if we don't have access to `jq` then we'll process the JSON
		## file using `sed` and just hope that the file format doesn't change
	DROPBOX_PATH=$(fgrep '"personal":' "$JSON" | sed 's#.*"path": "##g ; s#", .*##g')
fi

	## If DROPBOX_PATH is empty, something went wrong
if [[ "$DROPBOX_PATH" == "" ]]
then
	echo "${NAME-$0}: Unable to determine Dropbox path." >>/dev/stderr
	exit 2
fi

	## if DROPBOX_PATH is not a directory, something went wrong
if [[ ! -d "$DROPBOX_PATH" ]]
then
	echo "${NAME-$0}: Dropbox path '$DROPBOX_PATH' is not a directory." >>/dev/stderr
	exit 2
fi
##
## This is the end of the 'Check Dropbox Location' section
####################################################################################################

	## initialize a variable we'll want later
CHANGED=''

	## if the user did not supply any arguments, they probably do not understand how to use
	## the script, so we should do our best to explain it to them.
if [[ "$#" -lt "1" ]]
then
	echo "Error! '$0' needs at least one argument, a file or folder in your Dropbox folder."
	echo "Example:\n\t$0 ~/Dropbox/some/file/here.pdf"
	echo "Multiple files/folders can also be given at once:"
	echo "Example:\n\t$0 ~/Dropbox/some/file/here.pdf ~/Dropbox/another/file/name.docx"
	exit 2
fi


	## start a loop of all the arguments given
for i in "$@"
do

	[[ ! -e "$i" ]] && echo "$NAME: '$i' does not exist" >>/dev/stderr && continue

	i=($i(:A))

	case "$i" in
		${DROPBOX_PATH}/*)

				# echo "$i IS in Dropbox"
			:
		;;

		*)
			echo "$NAME: '$i' is NOT in Dropbox" >>/dev/stderr
			continue
		;;

	esac

	## if we get here then '$i' is either a file or folder in Dropbox
	## now we should check to see if it is already ignored

	echo "$NAME: checking status of '$i'..."

	STATUS=$(xattr -p com.dropbox.ignored "$i" 2>/dev/null)

	if [[ "$STATUS" == "1" ]]
	then
		echo "$NAME: '$i' is already set to be ignored." >>/dev/stderr
		continue
	fi

	## If we get here then the file/folder is NOT set to be ignored

	echo "$NAME: setting '$i' to be ignored..."

		# This is where we set the attribute to ignore the file/folder
	xattr -w com.dropbox.ignored 1 "$i"

		# now we check to see if it worked
	STATUS=$(xattr -p com.dropbox.ignored "$i" 2>/dev/null)

		# if STATUS = 1 then we're good, but tell the user either way
	if [[ "$STATUS" == "1" ]]
	then
		echo "👍 $NAME: Successfully set '$i' to be ignored."
		CHANGED="$i"
	else
		echo "⚠️ $NAME: FAILED to set '$i' to be ignored." >>/dev/stderr
	fi

done

## This is the end of the 'for' loop


## If the file/folder has been successfully ignored,
##	Dropbox will show a grey minus sign next to it in Finder.
##
## Since the "ignore" feature is listed as "in beta" the user might want to check.
##
## We cannot (easily) offer to show them _all_ of the files/folders we have processed,
## but we can ask them if they would like to check the _last_ file that was changed.
##
## The variable '$CHANGED' will have that file/folder path in it, and `open -R`
##	will reveal it in the Finder.
##
## If the variable '$CHANGED' is empty, that means we did not actually change
##	any files/folders, so we won't offer to do anything.

if [[ "$CHANGED" != "" ]]
then
		# Prompt the user. If they enter 'n' or 'N' it will not
		# 	be revealed. Otherwise it will be. The capital 'Y'
		#	indicates it is the default response, so even if the
		#	user just presses 'Enter' it will be revealed.
	read "?Reveal '$CHANGED' in Finder? [Y/n] " ANSWER

	case "$ANSWER" in
		N*|n*)
			echo "$NAME: OK, not showing '$CHANGED' in the Finder."
			exit 0
		;;

		*)
			echo "$NAME: Revealing '$CHANGED' in the Finder..."
			open -R "$CHANGED"
		;;
	esac

fi

exit 0
#EOF
