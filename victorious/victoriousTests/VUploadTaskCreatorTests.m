//
//  VUploadTaskCreatorTests.m
//  victorious
//
//  Created by Josh Hinman on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadManager.h"
#import "VUploadTaskCreator.h"
#import "VUploadTaskInformation.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface VUploadTaskCreatorTests : XCTestCase

@property (nonatomic, strong) id uploadManagerMock;
@property (nonatomic, strong) VUploadTaskCreator *uploadTaskCreator;
@property (nonatomic, strong) NSURL *uploadBodyFileURL;

@end

@implementation VUploadTaskCreatorTests

- (void)setUp
{
    [super setUp];

    self.uploadManagerMock = [OCMockObject mockForClass:[VUploadManager class]];

    NSString *folderName = [[NSUUID UUID] UUIDString];
    NSString *filename = [[NSUUID UUID] UUIDString];
    self.uploadBodyFileURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:folderName] stringByAppendingPathComponent:filename]];
    [[[self.uploadManagerMock stub] andReturn:self.uploadBodyFileURL] urlForNewUploadBodyFile];

    self.uploadTaskCreator = [[VUploadTaskCreator alloc] initWithUploadManager:self.uploadManagerMock];
}

/**
 Tests that a file exists in the spot where the upload body should be.
 Does NOT test that the contents of the file are correct
 */
- (void)testUploadBodyFileExists
{
    self.uploadTaskCreator.formFields = @{ @"hello": @"world" };
    VUploadTaskInformation *uploadTask = [self.uploadTaskCreator createUploadTaskWithError:nil];
    XCTAssertNotNil(uploadTask);
    
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self.uploadBodyFileURL path] isDirectory:&isDirectory];
    XCTAssertTrue(exists);
    XCTAssertFalse(isDirectory);
}

- (void)testPropertiesOfUploadTask
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]];
    NSString *description = @"my description";
    
    NSURL *previewImageFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"jpg"];
    UIImage *previewImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:previewImageFileURL]];
    
    self.uploadTaskCreator.request = request;
    self.uploadTaskCreator.uploadDescription = description;
    self.uploadTaskCreator.previewImage = previewImage;
    
    VUploadTaskInformation *uploadTask = [self.uploadTaskCreator createUploadTaskWithError:nil];
    XCTAssertEqualObjects(request.URL, uploadTask.request.URL);
    XCTAssertEqualObjects(request.httpMethod, uploadTask.request.httpMethod);
    XCTAssertEqualObjects(previewImage, uploadTask.previewImage);
    XCTAssertEqualObjects(description, uploadTask.uploadDescription);
}

@end
