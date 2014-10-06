#!/bin/bash
###########
# Creates a strings file that can be localized 
# from all the xib files in the Victorious code.
# 
###########

XIB_INFILE=$1
OUTDIR="./xib-strings"
OUTSUBDIR=$OUTDIR"/en.lproj"
MINFILESIZE=2


# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"
mkdir -p "$OUTSUBDIR"


# Process any xib passed in as a parameter
if [ "$XIB_INFILE" ]; then
    echo ""
    path=${XIB_INFILE/*}
    base=${XIB_INFILE##*/}
    fext=${base##*.}
    if [ $fext = "xib" ] || [ $fext = "storyboard" ]; then
        echo "Generating Strings File for $XIB_INFILE"
        stringsFile=${base%.*}.strings
        echo "$base -> $stringsFile"
        ibtool --generate-strings-file "$OUTSUBDIR/$stringsFile" "$XIB_INFILE"
        echo "Finished!"
    else
        echo "Error: Input file must be an xib or storyboard file... exiting now"
    fi
    echo ""
    exit 0
fi

echo ""
echo "Generating Strings Files"


# Sweep through project directory and locate all xib files
echo ""
echo "xibs..."
find . \( -name "*.xib" -or -name "*.storyboard" \) -print | grep '/en.lproj/' | while read -d $'\n' file
do
    path=${file/*}
    base=${file##*/}
    fext=${base##*.}

    if [ $fext = "xib" ] || [ $fext = 'storyboard' ]; then
        filename=$(basename $file)
        stringsFile=${base%.*}.strings

        echo "$base -> $stringsFile"

        ibtool --generate-strings-file "$OUTSUBDIR/$stringsFile" "$file"
        filesize=$(stat -f%z "$OUTSUBDIR/$stringsFile")
        if [ "$filesize" -le "$MINFILESIZE" ]; then
            rm "$OUTSUBDIR/$stringsFile"
            echo ""
            echo "Error: Cannot generate $base strings file"
            echo "Reason: Strings file is empty"
            echo ""
        else
            echo "$base -> $stringsFile"
        fi
    else
        echo ""
        echo "Skipping $file (Not a xib or storyboard file)"
        echo ""
    fi
done


echo ""
echo "Finished!"
echo ""
