#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: update_fzf_lists.sh
# 
#         USAGE: ./update_fzf_lists.sh 
# 
#   DESCRIPTION: updates list so fzf can use for searches.
#        titles.list is used by titles.sh (imdb)
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 10:27
#      REVISION:  2016-01-03 11:59
#===============================================================================

OUT=/Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/src

split_file() {
    STUB=$1

    echo "retrieve $STUB from sqlite..."
    sqlite3 imdb.sqlite "select $STUB from imdb;"  > $OUT/$STUB.tmp
    < $OUT/$STUB.list
    echo "remove space after comma in $STUB.tmp"
    sed 's/, /,/g' $OUT/$STUB.tmp | sponge $OUT/$STUB.tmp
    echo "splitting file on comma ..."
    while IFS=',' read -ra ADDR; do
        for i in "${ADDR[@]}"; do
            #i=$( echo "$i" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;' )
            echo "$i" >> $OUT/$STUB.list
        done
    done < $OUT/$STUB.tmp
    wc -l $OUT/$STUB.list
    echo "Sorting unique..."

    sort -u $OUT/$STUB.list | sponge $OUT/$STUB.list

    wc -l $OUT/$STUB.list
    rm $OUT/$STUB.tmp
}

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit 1
if [[ ! -f "imdb.sqlite" ]]; then
    echo "File: imdb.sqlite not found"
    exit 1
fi
echo "generating titles.list"
sqlite3 --separator $'\t' imdb.sqlite "select title, year from imdb;" | sort > $OUT/titles.list
wc -l $OUT/titles.list
echo

split_file "actors"
split_file "director"
