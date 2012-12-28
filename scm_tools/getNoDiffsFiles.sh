#!/bin/sh

ALL_FILES_LIST='/tmp/all_files.txt'
CHECK_FILES_LIST='/tmp/checked_files.txt'

cd $1

echo '' > $CHECK_FILES_LIST

cat $FILELIST | while read line; do
    if git diff --quiet master:$line refs/heads/open:$line ; then
	EQUAL='= '
    else
	EQUAL=''
    fi

    echo "$EQUAL $line" >> $CHECK_FILES_LIST
    
done
