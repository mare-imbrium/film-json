#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: alttitles.sh
# 
#         USAGE: ./alttitles.sh 
# 
#   DESCRIPTION: Takes the foreign title and supplies English IMDB display title if present, else all titles
#         
# 
#       OPTIONS: none.
#  REQUIREMENTS: gsed
#          BUGS: gsed;s case insensitive range search fails so you need to get case right. Sorry
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 11/30/2015 11:02
#      REVISION:  2015-12-22 14:57
#===============================================================================

set -o nounset                              # Treat unset variables as an error

source ~/bin/sh_colors.sh
APPNAME=$( basename $0 )
ext=${1:-"default value"}
today=$(date +"%Y-%m-%d-%H%M")
curdir=$( basename $(pwd))
#set -euo pipefail
export TAB=$'\t'



ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

    Given a foriegn title of a movie, checks aka-titles.list.utf-8 to see if 
      English imdb display title exists, and returns that.
    If not, it returns whatever alt titles it has.
    NOTE: the year of the IMDB English title is often years ahead of the original release
    so the year may not match.
    NOTE: foreign titles use accented and non-ascii characters.
    
  Usage :  ${0##/*/} [options] [--] <title of movie>

  Options: 
  -h|--help       Display this message
  -v|--version    Display script version
  -V|--verbose    Display processing information
  --no-verbose    Suppress extra information
  --debug         Display debug information

	EOT
}    # ----------  end of function usage  ----------


#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
OPT_VERBOSE=
OPT_DEBUG=
RDEBUG=:
while [[ $1 = -* ]]; do
case "$1" in
    -V|--verbose)   shift
                     OPT_VERBOSE=1
                     ;;
    --no-verbose)   shift
                     OPT_VERBOSE=
                     ;;
    --debug)        shift
                     OPT_DEBUG=1
                     RDEBUG=pdebug
                     ;;
    -h|--help)
        usage
        exit
    ;;
    *)
        echo "Error: Unknown option: $1" >&2   # rem _
        echo "Use -h or --help for usage"
        exit 1
        ;;
esac
done

title=
if [ $# -eq 0 ]
then
    perror "I got no title"
    exit 1
else
    $RDEBUG "Got $*"
    title="$*"
fi
[[ -z "$title" ]] && { echo "Error: title blank." 1>&2; exit 1; }
$RDEBUG "title is $title"

#gsed -n "/^$title/,/^$/Ip" aka-titles.list.utf-8 | grep imdb | cut -f1 | sed 's/^  *(aka//;s/)$//' | sed 's/^ *//'
items=$( gsed -n "/^${title}/,/^$/Ip" aka-titles.list.utf-8 )
$RDEBUG "items are:$items."
if [[ -z "$items" ]]; then
    echo "No matches found" 1>&2
    echo "Checking with grep. gsed case insensitive range search does not work"
    grep -A 4 -i "^${title}" aka-titles.list.utf-8
    exit 1
    
fi
leni=$( echo -e "${items}" | grep -c . )
$RDEBUG "$leni matches"
if [[ $leni -eq 0 ]]; then
    echo "No matches found" 1>&2
    grep -i "^${title}" aka-titles.list.utf-8
    exit 1
else
    $RDEBUG "found $leni matches"
fi
imdb=$( echo -e "$items" | grep imdb | grep English )
if [[ -z "$imdb" ]]; then
    imdb=$( echo -e "$items" | grep USA  )
fi
leni=$( echo -e "${imdb}" | grep -c . )
if [[ -z "$imdb" ]]; then
    echo "No English imdb matches found. Showing all ... " 1>&2
    echo "$items"
    exit
fi
$RDEBUG $imdb
echo -e "$imdb" | cut -f1 | sed 's/^  *(aka//;s/)$//' | sed 's/^ *//'
