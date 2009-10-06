#!/bin/sh

#
# add_shp2pgdb.sh
#
# Copyright (C) 2009 CartoLab. Universidade de A Coruña
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
# KEYWORDS: shell script, postgis, postgresql, database
#
# DEPENDENCIES: shp2pgsql (PostGis package)
#
# DESCRIPTION: add_shp2pgdb.sh  Takes a path to a directory that contains
# subdirectories with ESRI Shapefiles, converts the files to a PostgresSQL format
# within a directory baseDir/sql/... and create one table for each ESRI Shapefile
# in a given database"
#
#
# CHANGELOG:
#  4/10/2009. Creation


usage() {
    echo "$0 -ip serverIP -d bdName -u user -s schema - i baseDir"
    echo
    echo "DESCRIPTION: sqhp2sql_script.sh Takes a path to a directory that contains subdirectories with ESRI Shapefiles, converts the files to a PostgresSQL format within a directory baseDir/sql/... and create one table for each ESRI Shapefile in a given database"
    echo
    echo "-ip: The ip of the server where database is located"
    echo "-d: The name of the postgreSQL database where dump the ESRI Shapefiles"
    echo "-u: The authorized user in the database"
    echo "-s: The name of the schema for the tables in the database"
    echo "-i: The **absolute** path to the directory where you want to begin the search"
    echo "    for the ESRI Shapefiles"
    exit -1
}


while [ $# -gt 0 ] ; do
    case $1
        in
        -s)
            schema=$2
            shift 2
            ;;


        -d)
            bdName=$2
            shift 2
            ;;


        -u)
            user=$2
            shift 2
            ;;


        -i)
            baseDir=$2
            shift 2
            ;;


        -ip)
            serverIP=$2
            shift 2
            ;;


        *)
            usage
            ;;
    esac
done



# All input arguments must exists
if [-z $baseDir ] || [ -z $schema ] || [ -z $bdName ] || [ -z serverIP ] || [ -z $user ] ; then
    usage
fi




for file in $(find $baseDir -iname '*.shp') ; do

    tableName=$(echo $(basename $file) | cut -d'.' -f1)

    aux=$(dirname $file)
    outSQLFile="${baseDir}/sql/${aux#$baseDir}/$tableName"
    unset aux

    mkdir -p $(dirname $outSQLFile)

    shp2pgsql $file ${schema}.${tableName} $bdName  --log-file ${outSQLFile}_utf8.log  | iconv -f iso8859-1 -t utf8 -o ${outSQLFile}_utf8.sql
    echo "File ${outSQLFile}_utf8.sql created"

    psql -d $bdName -U $user -h $serverIP -f ${outSQLFile}_utf8.sql


done

exit 0