//
//  NSURL+VTemporaryFilesTests.m
//  victorious
//
//  Created by Michael Sena on 8/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSURL+VTemporaryFiles.h"

@interface NSURL_VTemporaryFilesTests : XCTestCase

@end

@implementation NSURL_VTemporaryFilesTests

- (void)testExample
{
    NSURL *urlForTempTestDir = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"test"];
    XCTAssert([[urlForTempTestDir pathExtension] isEqualToString:@"jpg"]);
    NSArray *pathCompontents = [urlForTempTestDir pathComponents];
    NSString *directoryName = pathCompontents[pathCompontents.count-2];
    XCTAssert([directoryName isEqualToString:@"test"]);
}

- (void)testThrowsExceptionsOnBadData
{
    XCTAssertNoThrow([NSURL v_temporaryFileURLWithExtension:nil inDirectory:@"test"]);
    XCTAssertThrows([NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:nil]);
    XCTAssertThrows([NSURL v_temporaryFileURLWithExtension:nil inDirectory:nil]);
}

- (void)testExtraSlashes
{
    NSURL *urlForTempDirExtraLeading = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"/test"];
    XCTAssertNotNil(urlForTempDirExtraLeading);
    NSURL *urlForTempDirExtraTrailing = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"test/"];
    XCTAssertNotNil(urlForTempDirExtraTrailing);
    NSURL *urlForTempDirExtraLeadingAndTrailing = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"/test/"];
    XCTAssertNotNil(urlForTempDirExtraLeadingAndTrailing);
}

- (void)testExtendedPaths
{
    NSURL *urlForExtendedPath = [NSURL v_temporaryFileURLWithExtension:nil inDirectory:@"/test/nestedTest"];
    NSArray *pathComponents = [urlForExtendedPath pathComponents];
    XCTAssert([pathComponents[pathComponents.count - 2] isEqualToString:@"nestedTest"]);
    XCTAssert([pathComponents[pathComponents.count - 3] isEqualToString:@"test"]);
}

@end
