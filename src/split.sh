#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: split.sh
# 
#         USAGE: ./split.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 10:35
#      REVISION:  2015-12-25 10:51
#===============================================================================

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit 1
if [[ ! -f "imdb.sqlite" ]]; then
    echo "File: imdb.sqlite not found"
    exit 1
fi
sqlite3 imdb.sqlite "select actors from imdb;"  > actors.tmp
< actors.list
echo "remove space after comma in actors.tmp"
sed 's/, /,/g' actors.tmp | sponge actors.tmp
echo "splitting file on comma ..."
while IFS=',' read -ra ADDR; do
      for i in "${ADDR[@]}"; do
          #i=$( echo "$i" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;' )
          echo "$i" >> actors.list
      done
done < actors.tmp
wc -l actors.list
echo "Sorting unique..."

sort -u actors.list | sponge actors.list

wc -l actors.list
rm actors.tmp
