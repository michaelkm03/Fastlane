//
//  VUploadTaskInformationTests.m
//  victorious
//
//  Created by Josh Hinman on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadTaskInformation.h"

#import <XCTest/XCTest.h>

@interface VUploadTaskInformationTests : XCTestCase

@end

@implementation VUploadTaskInformationTests

- (void)testIdentification
{
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:nil bodyFileURL:nil description:nil];
    VUploadTaskInformation *task2 = [[VUploadTaskInformation alloc] initWithRequest:nil bodyFileURL:nil description:nil];
    XCTAssertNotNil(task.identifier);
    XCTAssertNotEqual(task.identifier, task2.identifier);
}

@end
