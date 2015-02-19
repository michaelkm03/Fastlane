#!/bin/bash
###########
# Searches for uses of supplied constants
###########

SOURCE=$1
SEARCH_DIR=$2
PREFIX=$3

USAGE="Usage: <CSV Source File Name> <Directory to search> <prefix>"

if [ "$SOURCE" == "" ]; then
    echo -e "Please provide source file:\n$USAGE"
    exit 1
fi

if [ "$SEARCH_DIR" == "" ]; then
    echo -e "Please provide directory to search file:\n$USAGE"
    exit 1
fi

if [ "$PREFIX" == "" ]; then
    echo -e "Please provide variable name prefix:\n$USAGE"
    exit 1
fi

(cat $SOURCE ; echo) | while IFS=, read -r COLUMN_1 COLUMN_2
do
	if [[ $COLUMN_1 == *"//"* ]];
	then
        echo -e "$COLUMN_1"
	elif [ ${#COLUMN_1} == 0 ];
	then
		echo ""
	else
		SEARCH_RESULT=$(egrep --with-filename --include \*.m --line-number -r "$PREFIX$COLUMN_1" "$SEARCH_DIR")
		LINE_COUNT=$(echo "$SEARCH_RESULT" | wc -l)
		NUM_USES=$(($LINE_COUNT-1))

		#echo -e "$PREFIX$COLUMN_1: $NUM_USES"

		if [ $NUM_USES == 0 ];
		then
			echo -e "\t$PREFIX$COLUMN_1"
		fi
	fi
done