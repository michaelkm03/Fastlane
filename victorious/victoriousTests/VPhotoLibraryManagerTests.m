//
//  VPhotoLibraryManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 10/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsyncTestHelper.h"
#import "VPhotoLibraryManager.h"

#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@import AssetsLibrary;

@interface VPhotoLibraryManagerTests : XCTestCase

@property (nonatomic, strong) VPhotoLibraryManager *photoLibraryManager;
@property (nonatomic, strong) id mockAssetsLibrary;

@end

@implementation VPhotoLibraryManagerTests

- (void)setUp
{
    [super setUp];
    self.photoLibraryManager = [[VPhotoLibraryManager alloc] init];
    self.mockAssetsLibrary = [OCMockObject niceMockForClass:[ALAssetsLibrary class]];
    self.photoLibraryManager.assetsLibrary = self.mockAssetsLibrary;
}

- (void)testDefaultPhotoLibrary
{
    VPhotoLibraryManager *photoLibraryManager = [[VPhotoLibraryManager alloc] init];
    XCTAssertTrue([photoLibraryManager.assetsLibrary isKindOfClass:[ALAssetsLibrary class]]);
}

- (void)testSaveVideo
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/my/video/is/here.mp4"];
    [[[self.mockAssetsLibrary expect] andReturnValue:@(YES)] videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL];
    [[[self.mockAssetsLibrary expect] andDo:^(NSInvocation *invocation)
    {
        ALAssetsLibraryWriteVideoCompletionBlock completion = nil;
        [invocation getArgument:&completion atIndex:3];
        if (completion)
        {
            completion([NSURL URLWithString:@"asset://library/url"], nil);
        }
    }] writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:OCMOCK_ANY];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:videoURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertNil(error);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

- (void)testErrorWhenVideoIsIncompatible
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/my/video/is/here.mp4"];
    [[[self.mockAssetsLibrary expect] andReturnValue:@(NO)] videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:videoURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertEqualObjects(error.domain, VPhotoLibraryManagerErrorDomain);
        XCTAssertEqual(error.code, VPhotoLibraryManagerIncompatibleVideoErrorCode);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

- (void)testErrorFromSavingVideoPassedThrough
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/my/video/is/here.mp4"];
    NSError *saveError = [NSError errorWithDomain:@"ReallyBadError!" code:100 userInfo:nil];
    [[[self.mockAssetsLibrary expect] andReturnValue:@(YES)] videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL];
    [[[self.mockAssetsLibrary expect] andDo:^(NSInvocation *invocation)
    {
        ALAssetsLibraryWriteVideoCompletionBlock completion = nil;
        [invocation getArgument:&completion atIndex:3];
        if (completion)
        {
            completion(nil, saveError);
        }
    }] writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:OCMOCK_ANY];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:videoURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertEqualObjects(error, saveError);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

- (void)testSaveImage
{
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"jpg"];
    [[[self.mockAssetsLibrary expect] andDo:^(NSInvocation *invocation)
    {
        ALAssetsLibraryWriteVideoCompletionBlock completion = nil;
        [invocation getArgument:&completion atIndex:4];
        if (completion)
        {
            completion([NSURL URLWithString:@"asset://library/url"], nil);
        }
    }] writeImageToSavedPhotosAlbum:[OCMArg anyPointer] orientation:ALAssetOrientationUp completionBlock:OCMOCK_ANY];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:imageURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertNil(error);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

- (void)testErrorFromSavingImagePassedThrough
{
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"jpg"];
    NSError *saveError = [NSError errorWithDomain:@"ReallyBadError!" code:100 userInfo:nil];
    [[[self.mockAssetsLibrary expect] andDo:^(NSInvocation *invocation)
    {
        ALAssetsLibraryWriteVideoCompletionBlock completion = nil;
        [invocation getArgument:&completion atIndex:4];
        if (completion)
        {
            completion(nil, saveError);
        }
    }] writeImageToSavedPhotosAlbum:[OCMArg anyPointer] orientation:ALAssetOrientationUp completionBlock:OCMOCK_ANY];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:imageURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertEqualObjects(error, saveError);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

- (void)testErrorForUnknownAssetType
{
    NSURL *videoURL = [NSURL fileURLWithPath:@"/what/the/heck/is/this.thing"];
    
    BOOL __block called = NO;
    [self.photoLibraryManager saveMediaAtURL:videoURL toPhotoLibraryWithCompletion:^(NSError *error)
    {
        called = YES;
        XCTAssertEqualObjects(error.domain, VPhotoLibraryManagerErrorDomain);
        XCTAssertEqual(error.code, VPhotoLibraryManagerUnknownAssetTypeErrorCode);
    }];
    [self.mockAssetsLibrary verify];
    XCTAssertTrue(called);
}

@end
