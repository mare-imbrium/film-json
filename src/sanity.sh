#!/usr/bin/env bash

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/
 echo Sometimes the name of the file does not match the imdbID since the page was forwarded. Happened only once.
 echo ... checking ...
 grep -o 'imdbID":"tt[0-9]*"' tt*.json | tr -d '"' | sed 's/\./:/' > temp.t
 echo created temp.t
 wc -l temp.t
 echo now comparing each line
 echo
 awk -F: '{ if ($1 != $4) { print  "file: ", $1, ".json contains imdbID: ", $4; }}' temp.t
 echo
 echo
 echo if any tt ids  were reported, please cat those .json files and see the imdbId.
 echo if you already have a json file with that imdbID then you can delete this one.
 rm temp.t
