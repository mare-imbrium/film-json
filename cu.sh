#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: cu.sh
# 
#         USAGE: ./cu.sh 
# 
#   DESCRIPTION: first checks local if not present fetches row from IMDB website for given title
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/24/2015 11:17
#      REVISION:  2015-12-24 11:25
#===============================================================================

check_imdb.sh "$@" || titlesearch.sh "$@"
