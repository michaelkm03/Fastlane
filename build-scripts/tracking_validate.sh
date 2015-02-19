#!/bin/bash
###########
# Convenience script for using 'find_in_files.sh' designed to be
# called from root project folder.
###########

echo -e "\nMissing Events:"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/events.csv victorious/victorious VTrackingEvent

echo -e "\nMissing Keys:"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/keys.csv victorious/victorious VTrackingKey

echo -e "\nMissing Values:"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/values.csv victorious/victorious VTrackingValue