#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: titlesearch.sh
#  Description: searches imdb using api given a title. Can search for exact title by
#    default or a partial match giving multiple results, or return multiples for exact title.
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-07 - 09:01
#      License: MIT
#  Last update: 2016-01-24 21:19
# ----------------------------------------------------------------------------- #
#  titlesearch.sh  Copyright (C) 2012-2014 j kepler
#  Last update: 2016-01-24 21:19

source ~/bin/sh_colors.sh
# print a message to stderr, preceded by the script name
function warn () {
  echo -e "$0: $*" >&2
}
# default is title search
_Q="t"
outfile="search.out"

while [[ $1 = -* ]]; do
case "$1" in
    -s|--search)
                     _Q="s"
                     shift
                     ;;
     -V|--verbose)   shift
         # not used but added so it can be used in pipeline in cu.sh
         OPT_VERBOSE=1
         ;;
     -i|--ignore-case)   shift
         # not used but added so it can be used in pipeline in cu.sh
         ;;
     --bulk)   shift
         # in bulk mode we don't prompt for update, we save all except short/documentary and not yet released
         # those go into the reject dir
         OPT_BULK=1
         ;;
    -h|--help)
cat <<!
$0 Version: 0.0.0 Copyright (C) 2012 rkumar
This program does the following:.. 
        Searches imdb using ombdapi.com for movie based on title or partial match and returns json.
        Second parameter can be year.

        -s | --search
           To use a partial search, or get multiple matches for a film
        e.g.
        $0 Caught
        $0 Caught 1949
          Specify version by giving year
        $0 'The Prisoner of Zenda'
           returns only one version of the film, possibly earliest
        $0 -s 'The Prisoner of Zenda'
            returns multiple rows for each version
!
        # no shifting needed here, we'll quit!
        exit
        ;;
    *)
        echo "Error: Unknown option: $1" >&2   # rem _
        echo "Use -h or --help for usage"
        exit 1
        ;;
esac
done

if [ $# -eq 0 ]
then
    warn "I got no title"
    exit 1
fi
oldtitle="$1"
title=$( echo "$1" | sed "s/ /+/g")
fc=${title:0:2}
if grep -q "^tt[0-9][0-9]*$" <<< "$title"
then
    echo "Got a tt code ..."
    # this is a tt code.
    OPT_TT=1
    _Q="i"
fi
if [[ -z "$2" ]]; then
    year=""
else
    year="&y=$2"
fi
oldyear=$2
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata

if [[ -n "$OPT_TT" ]]; then
    wget -q -O $outfile "http://www.omdbapi.com/?${_Q}=${title}"'&plot=full&type=movie&r=json'
else
    wget -q -O $outfile "http://www.omdbapi.com/?${_Q}=${title}${year}"'&plot=full&type=movie&r=json'
fi

nosaveme=
if [[ ! -s "$outfile" ]]; then
    echo -e "Nothing received, maybe no internet connection?" 1<&2
    exit 1
else
    #echo result sent to $outfile
    #echo -e "\\033[1m ${oldtitle} ${oldyear}\\033[22m sent to $outfile "
    echo "$oldtitle $oldyear ~  sent to $outfile " | grep '.*~'
    cat $outfile | jq '.' | egrep 'Actors":|Genre":' | grep -E '".*?"'
    newtitle=$( cat $outfile | jq '.' | grep '"Title"' | cut -f2- -d':' | tr -d '"' )
    #actors=$(cat $outfile | jq '.' | grep Actors | grep -E '".*?"')
    #pinfo "$actors"
    # let's check if short or documentary or genre N/A
    # or year is higher than 2015 which means most data will not be there. So
    # we will put in reject dir
    # however, if Awards has some data then we want to store it here.
    nosaveme=$(cat $outfile | jq '.' | grep 'Genre":' | egrep 'Documentary|Short')
    if [[ -n "$nosaveme" ]]; then
        preverse "Documentary or Short found!"
    fi
    if [[ -z "$nosaveme" ]]; then
        nosaveme=$(cat $outfile | jq '.' | grep 'Genre": "N/A"' )
        if [[ -z "$nosaveme" ]]; then
            nosaveme=$(cat $outfile | jq '.' | grep 'Year": "201[6789]' )
        fi
    fi
    if [[ -n "$nosaveme" ]]; then
        preverse "Not worth saving ... $nosaveme"
    fi
fi
# requires my script which highlights these words without removing non-matching lines
cat $outfile | jq '.' | hl -n 'Documentary|Short'
if [[ $_Q == "t" || $_Q == "i" ]]; then
    # searched only one movie, see if we have it already in database
    id=`cat $outfile | jq '.imdbID' | tr -d '"' `
    if [[ "$id" == "null" ]]; then
        #echo -e "No such movie: ${title}" 1<&2
        preverse "No such movie: ${title}"
        echo -e "${title} :: not found" >> errors.list
        exit 1
    fi
    if [[ -n "$id" ]]; then
        echo "imdb Id is $id"
        jsonfile="${id}.json"
        if [[ ! -f "$jsonfile" ]]; then
            if [[ -n "$OPT_BULK" ]]; then
                if [[ -n "$nosaveme" ]]; then
                    ANSWER=N
                else
                    ANSWER=Y
                fi
            else
                echo "File: $jsonfile not found, Shall I write to $jsonfile?"
                read ANSWER < /dev/tty
            fi
            if [[ $ANSWER =~ [Yy] ]]; then
                echo "Writing $newtitle to $jsonfile" | grep '.'
                cp $outfile $jsonfile
                echo "$id" >> files.list
                echo -e "Importing into imdb table ..." 1<&2
                ./convert.rb $id
            else
                cp $outfile ./reject/$jsonfile
                preverse "written $newtitle to ./reject dir"
            fi
            #read XXX < /dev/tty
            sleep 1
        else
            echo "File: $jsonfile already exists." 1<&2
            diff <(cat $jsonfile | jq '.') <(cat search.out | jq '.') 
            if ! cmp $jsonfile search.out >/dev/null 2>&1
            then
                echo
                echo -n "Do you wish to update $jsonfile " '[y/n] ' ; read ANS < /dev/tty
                case "$ANS" in
                    y*|Y*) cp search.out "$jsonfile" 
                        echo "$id" >> update.list
                        ;;
                    *) echo "No action taken...";;
                esac
                # database needs to be updated with these
            fi

        fi
    fi
fi
