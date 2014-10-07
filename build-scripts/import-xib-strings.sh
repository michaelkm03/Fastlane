#!/bin/bash
###########
# Imports a strings file that can be localized 
# from all the xib files in the Victorious code.
# 
###########

STR_INFILE=$1
STR_DIR="./xib-strings"
LANG_DIR=$OUTDIR"/en.lproj"
DEST_DIR="./victorious/victorious/"


# Process any strings file passed in as a parameter
if [ "$STR_INFILE" ]; then
    echo ""
    path=${STR_INFILE/*}
    base=${STR_INFILE##*/}
    fext=${base##*.}
    filename=$(basename $STR_INFILE)
    xibname=${base%.*}.xib
    langdir=$( dirname "${STR_INFILE}" )
    lang=${langdir%.*}.lproj | grep '.lproj'

    if [ $fext = "strings" ]; then
        echo "Importing Strings File for $xibname"
        current_xib=$(find . -name "$xibname" -print | grep '/en.lproj/')
        dest_xib=${current_xib/en.lproj/'es.lproj'}
        echo "Current XIB: $current_xib"
        echo "Dest XIB: $dest_xib"
        ibtool --strings-file $STR_INFILE $current_xib --write $dest_xib
        echo "Finished!"
    else
        echo "Error: Input file must be a strings file... exiting now"
    fi
    echo ""
    exit 0
fi

echo ""
echo "Importing Localized Strings..."


# Sweep through project directory and locate all strings files
echo ""
find . \( -name "*.xib" -or -name "*.storyboard" \) -print | grep '/en.lproj/' | while read -d $'\n' xib_file
do
    path=${xib_file/*}
    base=${xib_file##*/}
    fext=${xib_file##*.}

    echo "File: $base"
    strings_file="./xib-strings/en.lproj/"${base%.*}.strings
    
    if [ -e "$strings_file" ]; then
        dest_xib=${xib_file/en.lproj/'es.lproj'}
        ibtool --strings-file $strings_file $xib_file --write $dest_xib
        echo "Current XIB: $current_xib"
        echo "Dest XIB: $dest_xib"
        echo ""
    else
        echo "$xib_file.strings does not exists"
        echo ""
    fi
done


echo ""
echo "Finished!"
echo ""
