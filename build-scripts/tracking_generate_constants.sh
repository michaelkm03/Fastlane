#!/bin/bash
###########
# Parses a CSV of tracking event names into Objective-C constants
###########

SOURCE=$1
DESTINATION=$2
PREFIX=$3
CLEAR_EXISTING=$4

THIS_FILE=`basename $0`

USAGE="Usage: <CSV Source File Name> <Destination File Name> <Variable Prefix> [--clear]"

if [ "$SOURCE" == "" ]; then
    echo -e "Please provide source file:\n$USAGE"
    exit 1
fi

if [ "$DESTINATION" == "" ]; then
    echo -e "Please provide destination file names (excluding extension):\n$USAGE"
    exit 1
fi

if [ "$PREFIX" == "" ]; then
    echo -e "Please provide variable name prefix:\n$USAGE"
    exit 1
fi

DATE="$(date +'%m/%d/%y')"
YEAR="$(date +'%Y')"

write_boilerplate ()
{
    INPUT_FILENAME=$1
    FILE_BOILERPLATE="
    //
    \n//  $1
    \n//  victorious
    \n//
    \n//  Generated from CSV using script \"$THIS_FILE\" on $DATE.
    \n//  Copyright (c) $YEAR Victorious. All rights reserved.
    \n//
    \n"

    echo -e $FILE_BOILERPLATE > $INPUT_FILENAME
}

HEADER_FILE="$DESTINATION.h"
IMPLEMENTATION_FILE="$DESTINATION.m"

if [ "$CLEAR_EXISTING" != "" ]; then

	write_boilerplate $HEADER_FILE
	write_boilerplate $IMPLEMENTATION_FILE

  HEADER_IMPORT_FILENAME=`basename $HEADER_FILE`

	echo -e "#import <Foundation/Foundation.h>\n" >> $HEADER_FILE
	echo -e "#import \"$HEADER_IMPORT_FILENAME\"\n" >> $IMPLEMENTATION_FILE

else

	echo -e "" >> $HEADER_FILE
	echo -e "" >> $IMPLEMENTATION_FILE
fi

(cat $SOURCE ; echo) | while IFS=, read -r COLUMN_1 COLUMN_2
do
	if [[ $COLUMN_1 == *"//"* ]];
	then
    echo -e "$COLUMN_1" >> $HEADER_FILE
    echo -e "$COLUMN_1" >> $IMPLEMENTATION_FILE

	elif [ ${#COLUMN_1} == 0 ];
	then
    echo -e "" >> $HEADER_FILE
    echo -e "" >> $IMPLEMENTATION_FILE

	else
		DECLARATION="$PREFIX$COLUMN_1"
		DEFINITION="@\"$COLUMN_1\""

		if [ ${#COLUMN_2} != 0 ]; then
			COMMENT="//< $COLUMN_2"
		else
			COMMENT=""
		fi

    echo -e "extern NSString * const $DECLARATION; $COMMENT" >> $HEADER_FILE
    echo -e "NSString * const $DECLARATION = $DEFINITION;" >> $IMPLEMENTATION_FILE
	fi

done
