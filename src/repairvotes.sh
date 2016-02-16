#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: repairvotes.sh
# 
#         USAGE: ./repairvotes.sh 
# 
#   DESCRIPTION: The imdbVotes coumn had commas in it so sqlite could not order correctly, we are pulling out
#   the rows and updating them after removing comma.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/22/2015 19:27
#      REVISION:  2015-12-22 19:52
#===============================================================================

SQLITE=$(brew --prefix sqlite)/bin/sqlite3

echo "Fetching votes from imdb ..."
$SQLITE imdb.sqlite "select imdbVotes, rowid from imdb where imdbVotes != 'N/A';" > t.t
echo "Done"
wc -l t.t

echo "removing commas and replacing N/A with zero"
#gsed 's/,//g;s|N/A|0|' t.t | sponge t.t
gsed 's/,//g;' t.t | sponge t.t
awk -F'|' '{ printf("update imdb set imdbVotes = %d where rowid =  %s;\n", $1, $2);  }' OFS='|' t.t  > t.1
head t.1
wc -l t.1
echo "Press Enter to update database or Control C to inspect t.1"
read
echo "Will take a minute or so to complete...."
$SQLITE imdb.sqlite < t.1
echo over
echo
echo "Displaying top 10 votes ..."
echo 
$SQLITE imdb.sqlite <<!
SELECT 
imdbID,
Title,
imdbRating,
imdbVotes
FROM imdb
WHERE imdbVotes != "N/A"
order by imdbVotes desc
LIMIT 10;
!
