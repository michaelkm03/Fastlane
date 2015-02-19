#!/bin/bash
###########
# Convenience script for using 'find_in_files.sh' designed to be
# called from root project folder.
###########

LINE="  ***************  "

echo -e "\n $LINE Missing Events $LINE"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/events.csv victorious/victorious VTrackingEvent

echo -e "\n $LINE Missing Keys $LINE"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/keys.csv victorious/victorious VTrackingKey

echo -e "\n $LINE Missing Values $LINE"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/values.csv victorious/victorious VTrackingValue