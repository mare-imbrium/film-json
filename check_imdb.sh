#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: check_imdb.sh
# 
#         USAGE: ./check_imdb.sh <title|ttcode>   # can return multiple rows
#         USAGE: ./check_imdb.sh <title> <year>
#         USAGE: ./check_imdb.sh --verbose <title> <year>
# 
#   DESCRIPTION: checks if record exists in local imdb database
#                   and prints entire content using LINE mode (verbose)
#                returns exit code 1 if not found
#               Takes STDIN also
#               If no arg passed, then reads from STDIN
# 
#       OPTIONS: --verbose   to print result
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/14/2015 20:43
#      REVISION:  2015-12-23 18:56
#===============================================================================

# check to see if title exists in local database.
# prints all data for title or imdbid in line mode
check_title() {
[[ -z "$PATT" ]] && { echo "Error: movie blank." 1>&2; exit 1; }

PATT=$( echo "$PATT" | sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g;' )
if [[ -n "$OPT_YEAR" ]]; then
    WHERE_YEAR=" AND YEAR = \"$OPT_YEAR\" "
fi

MYCOL='title'
if grep -q "^tt[0-9][0-9]*$" <<< "$PATT"; then
    MYCOL=imdbID
fi
if [[ -n "$OPT_CASE" ]]; then
    MYOPERATOR=LIKE
else
    MYOPERATOR='='

fi
if [[ $PATT = *%* ]]; then
    MYOPERATOR=LIKE
fi
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE=imdb.sqlite
RESULT=$( $SQLITE $MYDATABASE <<!
.mode line
  select * FROM imdb WHERE $MYCOL $MYOPERATOR "${PATT}" ${WHERE_YEAR};
!
)
if [[ -n "$RESULT" ]]; then
    if [[ -n "$OPT_VERBOSE" ]]; then
        echo -e "$RESULT"
    fi
    exit 0
else
    # although this breaks the loop, but we need this if we need to OR this in a pipe
    exit 1
fi
}

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata || exit 1

OPT_VERBOSE=
OPT_DEBUG=
OPT_CASE=
while [[ $1 = -* ]]; do
    case "$1" in
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        -i|--ignore-case)   shift
            OPT_CASE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        --bulk)        shift
            # this is passed to titlesearch.sh
            OPT_BULK=1
            ;;
        -h|--help)
            cat <<-!
$0 Version: 0.0.0 Copyright (C) 2015 jkepler
This program checks the local IMDB database to see if there is an entry for the given movie, or imdbID.
   Options:
   -V   --verbose       print result if found. Otherwise returns a code of 0 or 1.
   -i   --ignore-case   Case insensitive search.
!
            exit
            ;;
        --edit)
            echo "this is to edit the file generated if any "
            exit
            ;;
        --source)
            echo "this is to edit the source "
            vim $0
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   
            echo "Use -h or --help for usage" 1>&2
            exit 1
            ;;
    esac
done

# if no args then read from stdin like a filter
OPT_YEAR=
if [  $# -eq 0 ]; then
    #PATT=$(rlwrap -pYellow -S 'Movie name? ' -H ~/.HISTFILE_MOVIETITLE -P "" -o cat)
    while IFS='' read line
    do
        PATT="$line"
        check_title
    done 
else
    # loop through command line args
    PATT="$1"
    OPT_YEAR="$2"
    check_title
    #for var in "$@"
    #do
        #PATT="$var"
        #check_title
    #done
    #PATT="$*"
fi
