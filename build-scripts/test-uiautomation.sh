#!/bin/bash
    
xcodebuild test -workspace victorious/victorious.xcworkspace -scheme debug-victorious -destination 'platform=iOS Simulator,name=iPhone 6'
TEST_RESULT=$?

git add --all
git commit -m "Updated test report."
git push origin master

exit $TEST_RESULT