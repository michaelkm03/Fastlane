#!/bin/bash
###########
# Convenience script for using 'generate_tracking_constants.sh' designed to be
# called from root project folder.
###########

DESTINATION_DIR="victorious/victorious/Managers/Tracking/VTrackingConstants"

# Create events using --clear flag to start fresh with a new file
./build-scripts/tracking_generate_constants.sh build-scripts/tracking_csv/events.csv $DESTINATION_DIR $FILENAME VTrackingEvent --clear

# Add keys and values onto file created above
./build-scripts/tracking_generate_constants.sh build-scripts/tracking_csv/keys.csv $DESTINATION_DIR $FILENAME VTrackingKey
./build-scripts/tracking_generate_constants.sh build-scripts/tracking_csv/values.csv $DESTINATION_DIR $FILENAME VTrackingValue;