#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: get_title_for_imdbid.sh
# 
#         USAGE: get_title_for_imdbid.sh ttcode
# 
#   DESCRIPTION: fetches the title given an imdb id
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/14/2015 20:43
#      REVISION:  2015-12-17 00:23
#===============================================================================

if [  $# -eq 0 ]; then
    PATT=$(rlwrap -pYellow -S 'IMDB Id? ' -H ~/.HISTFILE_IMDBID -P "" -o cat)
else
    PATT="$*"
fi
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata || exit 1

[[ -z "$PATT" ]] && { echo "Error: imdb id blank. e.g tt0012345." 1>&2; exit 1; }

MYOPERATOR='='
#if [[ $PATT = *%* ]]; then
    #MYOPERATOR=LIKE
#fi
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE=imdb.sqlite
$SQLITE $MYDATABASE <<!
.mode tabs
  select title, year from imdb where imdbId $MYOPERATOR "${PATT}";
!
