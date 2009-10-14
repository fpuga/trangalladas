#!/bin/sh

#
# insert_folder_in_filename.sh
#
# Copyright (C) 2009 Francisco Puga. http://conocimientoabierto.es
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# AUTHORS:
# Francisco Puga Alonso <fran.puga@gmail.com>
#
# KEYWORDS: shell script, rename, directory tree, 
#
# DEPENDENCIES:
#
# DESCRIPTION: insert_folder_in_filename.sh search recursively (entering 
# subdirectories) all files from an inicial directory and copy each file to 
# a given directory with a name like 
# <directory_name_that_contains the file>-filename
#
# CHANGELOG:
#  14/10/2009. Creation


usage() {
    echo
    echo "`basename $0` -i initial_directory -o output_directory"
    echo
    echo "DESCRIPTION: insert_folder_in_filename.sh search recursively (entering subdirectories) all files from an inicial directory and copy each file to a given directory with a name like <directory_name_that_contains the file>-filename"
    echo "BE AWARE: if directories or files contain spaces in the names script may fail"
    echo
    echo "-i: The inicial directory where begin the search of files"
    echo "-o: The outpu_directory where place the renamed files"
    exit -1
}


indir='.'
outdir='.'
i=0

IFS='
'


while [ $# -gt 0 ] ; do
    case $1
        in
        -i)
            indir=$2
            shift 2
            ;;


        -o)
            outdir=$2
            shift 2
            ;;

        *)
            usage
            ;;
    esac
done


if ! [ -d $outdir ] ; then echo "Destiny folder doesn't exist"; exit -1; fi

for if in `find $indir -type f -iname '*'` ; do
    str=`dirname $if`
    prefix=`expr "$str" : '.*\(/.*\)' | cut -d'/' -f2`
    of=${prefix}-`basename $if`

    if [ -e "${outdir}/$of" ] ; then
        cp $if ${outdir}/${i}-${of}
        let i++
    else
        cp "$if"  ${outdir}/$of
    fi
done

exit 0