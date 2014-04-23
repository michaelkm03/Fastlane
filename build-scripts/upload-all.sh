#!/bin/bash
###########
# Uploads all apps in the 'products' folder to TestFlight.
###########

find configurations -type d -depth 1 -print0 | xargs -0 -n 1 build-scripts/upload-to-testflight.sh
