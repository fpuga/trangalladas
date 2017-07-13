#!/bin/bash

# sudo apt-get install mdbtools

mdb-schema $1 postgres > $1_schema_postgres.sql

for table in `mdb-tables $1` ; do 
    mdb-export -I postgres -q "'" $1 $table > $table.sql
    mdb-prop $1 $table > $table.txt
    mdb-export $1 $table > $table.csv
done
