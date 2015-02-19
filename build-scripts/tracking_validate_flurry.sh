#!/bin/bash
###########
# Convenience script for using 'find_in_files.sh' designed to be
# called from root project folder.
###########

echo -e "\nMissing Events from Flurry EatYourKimchi as of 2/18/15"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/flurry_events_eyk.csv victorious/victorious VTrackingEvent

echo -e "\nMissing Events from Flurry GlamLifeGuru as of 2/18/15"
./build-scripts/find_in_files.sh build-scripts/tracking_csv/flurry_events_glg.csv victorious/victorious VTrackingEvent