#!/bin/bash
###########
# Creates a strings file that can be localized 
# from all the xib files in the Victorious code.
# 
###########

XIB_INFILE=$1
STR_OUTFILE=$2

if [ "$XIB_INFILE" == "" || "$STR_OUTFILE" == "" ]; then
    echo "Usage: `basename $0` [-i <xib-to-stringify>] [-o <name of string file to output>]"
    echo ""
	echo "If you leave off the -o param, the script will run through the entire Xcode project."
	echo "If you only want one file to be converted, be sure to include the -o param."
    exit 1
fi

