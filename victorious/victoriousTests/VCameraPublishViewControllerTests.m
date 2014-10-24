//
//  VCameraPublishViewControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VCameraPublishViewController.h"

@interface VCameraPublishViewController (UnitTests)

- (void)correctPreviewImageRotation;
@property (nonatomic, assign) BOOL isPreviewImageRotationCorrected;

@end

@interface VCameraPublishViewControllerTests : XCTestCase

@property (nonatomic, strong) VCameraPublishViewController *viewController;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VCameraPublishViewControllerTests

- (void)setUp
{
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"sampleImage" ofType:@"jpg"];
    self.previewImage = [UIImage imageWithContentsOfFile:path];
    XCTAssertNotNil( self.previewImage );
    
    self.viewController = [[VCameraPublishViewController alloc] init];
    self.viewController.previewImage = self.previewImage;
    
    XCTAssertFalse( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.previewImage, self.viewController.previewImage );
}

- (void)testRotationCorrectionRequired
{
    self.viewController.mediaURL = [NSURL URLWithString:@"video.mp4"];
    self.viewController.didSelectAssetFromLibrary = YES;
    
    [self.viewController correctPreviewImageRotation];
    XCTAssert( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertNotEqualObjects( self.viewController.previewImage, self.previewImage,
                             @"A new rotated image should have been created." );
    UIImage *rotatedImage = self.viewController.previewImage;
    
    // Test calling again to make sure image is not rotated again
    [self.viewController correctPreviewImageRotation];
    XCTAssert( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.viewController.previewImage, rotatedImage,
                          @"Image should not have been recreated." );
}

- (void)testRotationCorrectionNotRequired
{
    self.viewController.mediaURL = [NSURL URLWithString:@"image.jpg"];
    self.viewController.didSelectAssetFromLibrary = YES;
    
    [self.viewController correctPreviewImageRotation];
    XCTAssertFalse( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.viewController.previewImage, self.previewImage );
    
    self.viewController.mediaURL = [NSURL URLWithString:@"image.jpg"];
    self.viewController.didSelectAssetFromLibrary = NO;
    
    [self.viewController correctPreviewImageRotation];
    XCTAssertFalse( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.viewController.previewImage, self.previewImage );
    
    self.viewController.mediaURL = [NSURL URLWithString:@"video.mp4"];
    self.viewController.didSelectAssetFromLibrary = NO;
    
    [self.viewController correctPreviewImageRotation];
    XCTAssertFalse( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.viewController.previewImage, self.previewImage );
    
    self.viewController.mediaURL = nil;
    self.viewController.didSelectAssetFromLibrary = NO;
    
    [self.viewController correctPreviewImageRotation];
    XCTAssertFalse( self.viewController.isPreviewImageRotationCorrected );
    XCTAssertEqualObjects( self.viewController.previewImage, self.previewImage );
}

@end
