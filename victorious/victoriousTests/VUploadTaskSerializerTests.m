//
//  VUploadTaskSerializerTests.m
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VUploadTaskInformation.h"
#import "VUploadTaskSerializer.h"

@interface VUploadTaskSerializerTests : XCTestCase

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) VUploadTaskSerializer *serializer;

@end

@implementation VUploadTaskSerializerTests

- (void)setUp
{
    [super setUp];
    NSString *filename = [[NSUUID UUID] UUIDString];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    self.fileURL = [NSURL fileURLWithPath:filePath];
    self.serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.fileURL];
}

- (void)tearDown
{
    [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:nil];
    [super tearDown];
}

- (void)testFileURL
{
    XCTAssertEqualObjects(self.fileURL, self.serializer.fileURL);
}

- (void)testSerialization
{
    NSURLRequest *request1 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.request1.com/"]];
    NSURLRequest *request2 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.request2.com/"]];
    NSURL *bodyFileURL1 = [NSURL fileURLWithPath:@"/bodyFile1"];
    NSURL *bodyFileURL2 = [NSURL fileURLWithPath:@"/bodyFile2"];
    NSString *description1 = @"fileDescription1";
    NSString *description2 = @"fileDescription2";
    VUploadTaskInformation *uploadTask1 = [[VUploadTaskInformation alloc] initWithRequest:request1 previewImage:nil bodyFileURL:bodyFileURL1 description:description1];
    VUploadTaskInformation *uploadTask2 = [[VUploadTaskInformation alloc] initWithRequest:request2 previewImage:nil bodyFileURL:bodyFileURL2 description:description2];
    
    if (![self.serializer saveUploadTasks:@[uploadTask1, uploadTask2]])
    {
        XCTFail(@"failed to save uploads");
        return;
    }
    
    VUploadTaskSerializer *serializer2 = [[VUploadTaskSerializer alloc] initWithFileURL:self.fileURL];
    NSArray *deserialized = [serializer2 uploadTasksFromDisk];
    
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[0] request], request1);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[0] bodyFileURL], bodyFileURL1);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[0] uploadDescription], description1);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[0] identifier], uploadTask1.identifier);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[1] request], request2);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[1] bodyFileURL], bodyFileURL2);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[1] uploadDescription], description2);
    XCTAssertEqualObjects([(VUploadTaskInformation *)deserialized[1] identifier], uploadTask2.identifier);
}

@end
