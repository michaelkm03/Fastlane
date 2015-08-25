#!/bin/bash

TEST_REPORT_FILE="UI-Automation-Tests.md"
TEST_REPORT_REPO="../VictoriousiOS.wiki"
    
echo -n "" > /tmp/filename

xcodebuild test \
    -workspace victorious/victorious.xcworkspace \
    -scheme debug-victorious \
    -destination 'platform=iOS Simulator,name=iPhone 6'

TEST_RESULT=$?

cd $TEST_REPORT_REPO
DIFF=`git diff`

if [ $TEST_RESULT -eq 0 ]; then
    echo "Tests succeeded."

    if [ -n "$DIFF" ]; then
        # TODO: Send email?
        echo "Pushing test report to Wiki."
        git add --all
        git commit -m "Updated test report."
        git push origin master
    fi
else
    # If the tests failed, undo the changes made while writing the test report
    echo "Tests failed."
    if [ -n "$DIFF" ]; then
        git checkout $TEST_REPORT_FILE
        echo "Undoing Wiki changes."
    fi
fi

exit $TEST_RESULT
