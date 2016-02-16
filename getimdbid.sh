#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: getimdbid.sh
# 
#         USAGE: ./getimdbid.sh 
# 
#   DESCRIPTION: fetches the imdb id for a given movie name. Uses exact search unless % found in string.
#      Then LIKE search is used.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/14/2015 20:43
#      REVISION:  2015-12-15 12:20
#===============================================================================

if [  $# -eq 0 ]; then
    PATT=$(rlwrap -pYellow -S 'Movie name? ' -H ~/.HISTFILE_MOVIETITLE -P "" -o cat)
else
    PATT="$*"
fi
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata || exit 1

[[ -z "$PATT" ]] && { echo "Error: movie blank." 1>&2; exit 1; }

MYOPERATOR='='
if [[ $PATT = *%* ]]; then
    MYOPERATOR=LIKE
fi
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE=imdb.sqlite
$SQLITE $MYDATABASE <<!
.mode tabs
  select imdbId, title, year from imdb where title $MYOPERATOR "${PATT}";
!
