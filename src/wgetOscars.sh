#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: wgetOscars.sh
#  Description: wget's the oscar files from imdb and puts them in the oscars dir.
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-08 - 18:47
#      License: MIT
#  Last update: 2015-11-09 11:41
# ----------------------------------------------------------------------------- #
#  YFF Copyright (C) 2012-2014 j kepler
#  Last update: 2015-11-09 11:41

# print a message to stderr, preceded by the script name
function warn {
  echo -e "$0: $*" >&2
}

# stub will be "oscars" or "cannes"
stub="$1" 

for url in `cat $stub.list`; do
    echo "URL:$url ..."
    year=$(echo "$url" | cut -f6 -d"/")
    echo "Year: $year"
    outfile=$stub/${year}
    if [[ ! -f "$outfile" ]]; then
        wget -q -O $outfile $url
        sleep 3
    else
        warn "Already downloaded $outfile"
    fi
done
exit
## vim:ts=4:sw=4:tw=100:ai:nowrap:formatoptions=croqln:filetype=sh
