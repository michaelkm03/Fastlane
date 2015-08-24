#!/bin/bash
    
xcodebuild test -workspace victorious/victorious.xcworkspace -scheme debug-victorious -destination 'platform=iOS Simulator,name=iPhone 6'
TEST_RESULT=$?

cd ../VictoriousiOS.wiki

DIFF=`git diff`
if [! -z DIFF]; then
    echo "Notify someone about an update to the test report!"
fi

git add --all
git commit -m "Updated test report."
git push origin master

exit $TEST_RESULT