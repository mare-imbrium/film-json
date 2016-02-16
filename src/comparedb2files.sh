#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: comparedb2files.sh
# 
#         USAGE: ./comparedb2files.sh 
# 
#   DESCRIPTION:  Compare imdb ids in database with those in files to see which ones we have not uploaded.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/22/2015 00:35
#      REVISION:  2015-12-22 00:50
#===============================================================================

SQLITE=$(brew --prefix sqlite)/bin/sqlite3
$SQLITE imdb.sqlite "select imdbID from imdb order by imdbID;" > t.t
ls *.json | sed 's/\.json//' | sort > t.1
echo
wc -l t.t t.1
echo
echo "Database does not have these imdbIDs:"
comm -13 t.t t.1
rm t.t t.1
