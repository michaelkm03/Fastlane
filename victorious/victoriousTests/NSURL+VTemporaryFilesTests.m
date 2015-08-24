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

- (void)testGoodData
{
    NSURL *urlForTempTestDir = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"test"];
    XCTAssert([[urlForTempTestDir pathExtension] isEqualToString:@"jpg"]);
    NSArray *pathCompontents = [urlForTempTestDir pathComponents];
    NSString *directoryName = pathCompontents[pathCompontents.count-2];
    XCTAssert([directoryName isEqualToString:@"test"]);
    
    [self canWriteToFile:urlForTempTestDir];
}

- (void)testThrowsExceptionsOnBadData
{
    XCTAssertNoThrow([NSURL v_temporaryFileURLWithExtension:nil inDirectory:@"test"]);
}

- (void)testExtraSlashes
{
    NSURL *urlForTempDirExtraLeading = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"/test"];
    XCTAssertNotNil(urlForTempDirExtraLeading);
    [self canWriteToFile:urlForTempDirExtraLeading];
    
    NSURL *urlForTempDirExtraTrailing = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"test/"];
    XCTAssertNotNil(urlForTempDirExtraTrailing);
    [self canWriteToFile:urlForTempDirExtraTrailing];
    
    NSURL *urlForTempDirExtraLeadingAndTrailing = [NSURL v_temporaryFileURLWithExtension:@"jpg" inDirectory:@"/test/"];
    XCTAssertNotNil(urlForTempDirExtraLeadingAndTrailing);
    [self canWriteToFile:urlForTempDirExtraLeadingAndTrailing];
}

- (void)testExtendedPaths
{
    NSURL *urlForExtendedPath = [NSURL v_temporaryFileURLWithExtension:nil inDirectory:@"/test/nestedTest"];
    NSArray *pathComponents = [urlForExtendedPath pathComponents];
    XCTAssert([pathComponents[pathComponents.count - 2] isEqualToString:@"nestedTest"]);
    XCTAssert([pathComponents[pathComponents.count - 3] isEqualToString:@"test"]);
    [self canWriteToFile:urlForExtendedPath];
}

- (void)canWriteToFile:(NSURL *)fileURL
{
    NSArray *anArray = @[@1, @2, @3];
    NSData *someData = [NSKeyedArchiver archivedDataWithRootObject:anArray];
    
    BOOL success = [someData writeToFile:fileURL.path
                              atomically:YES];
    XCTAssert(success);
}

@end
