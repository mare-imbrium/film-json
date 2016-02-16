#!/usr/bin/env zsh
export COLOR_RED="\\033[0;31m"
export COLOR_DEFAULT="\\033[0m"
echo "Dataase contains:"
sqlite3 imdb.sqlite "select count(*) from imdb"
echo
echo "Files in directory are: "
#ls *.json | wc -l
ls *.json | grep -c '.'

echo
echo checking for JSON files with errors
echo This could be due to incorrect IMDB id
echo Or because the film is new and omdbapi has not yet updated it
echo
echo Files containing Error tag
echo

echo -e "$COLOR_RED "

grep --colour=never '"Error":' *.json
echo -e "$COLOR_DEFAULT"

echo
echo Another test
echo Files not containing Title tag
echo
echo -e "$COLOR_RED"

grep -v '"Title":' *.json

echo -e "$COLOR_DEFAULT"
echo
echo If any files were reported, check www.imdb.com for these ids. Either correct them if wrong, or 
echo try in a month or so if its a new film
