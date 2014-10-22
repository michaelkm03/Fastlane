//
//  VVoteTypeImageSerializationTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDummyModels.h"
#import "VTracking+RestKit.h"
#import "VVoteType+ImageSerialization.h"
#import "VTrackingConstants.h"

@interface VVoteTypeImageSerializationTests : XCTestCase

@property (nonatomic, strong) VVoteType *voteType;

@end

@implementation VVoteTypeImageSerializationTests

- (void)setUp
{
    [super setUp];
    
    self.voteType = [VDummyModels createVoteTypes:1].firstObject;
    self.voteType.imageCount = @( 10 );
    self.voteType.imageFormat = [NSString stringWithFormat:@"image_%@.png", VVoteTypeImageIndexReplacementMacro];
    
    XCTAssert( self.voteType.canCreateImages );
    XCTAssert( self.voteType.containsRequiredData );
    XCTAssert( self.voteType.hasValidTrackingData );
}

- (void)testCreateImageUrls
{
    NSArray *images = self.voteType.images;
    
    XCTAssertNotNil( images );
    XCTAssert( [images isKindOfClass:[NSArray class]] );
    XCTAssertEqual( images.count, self.voteType.imageCount.unsignedIntegerValue );
    
    [images enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL *stop) {
        XCTAssert( [imageUrl rangeOfString:VVoteTypeImageIndexReplacementMacro].location == NSNotFound );

#warning This is only until the backend is updated.  Should be 5 digits.
        NSString *number = [NSString stringWithFormat:@"0%lu", (unsigned long)idx];
        
        NSString *expectedUrl = [self.voteType.imageFormat stringByReplacingOccurrencesOfString:VVoteTypeImageIndexReplacementMacro withString:number];
        XCTAssertEqualObjects( imageUrl, expectedUrl );
    }];
}

- (void)testCountInvalid
{
    self.voteType.imageCount = @(0);
    XCTAssertFalse( self.voteType.canCreateImages );
    XCTAssertNil( self.voteType.images );
    
    self.voteType.imageCount = nil;
    XCTAssertFalse( self.voteType.canCreateImages );
    XCTAssertNil( self.voteType.images );
}

- (void)testFormatInvalid
{
    self.voteType.imageFormat = nil;
    XCTAssertFalse( self.voteType.canCreateImages );
    XCTAssertNil( self.voteType.images );
    
    self.voteType.imageFormat = @"";
    XCTAssertFalse( self.voteType.canCreateImages );
    XCTAssertNil( self.voteType.images );
    
    self.voteType.imageFormat = @"image_00000.png";
    XCTAssertFalse( self.voteType.canCreateImages );
    XCTAssertNil( self.voteType.images );
}

- (void)testContainsInvalidData
{
    self.voteType.name = nil;
    XCTAssertFalse( self.voteType.containsRequiredData );
    
    self.voteType.name = @"";
    XCTAssertFalse( self.voteType.containsRequiredData );
}

- (void)testContaintsInvalidTrackingData
{
    self.voteType.tracking.ballisticCount = @[ [NSNull null], [NSNull null] ];
    XCTAssertFalse( self.voteType.hasValidTrackingData );
    
    self.voteType.tracking.ballisticCount = @[];
    XCTAssertFalse( self.voteType.hasValidTrackingData );
    
    self.voteType.tracking.ballisticCount = nil;
    XCTAssertFalse( self.voteType.hasValidTrackingData );
    
    self.voteType.tracking = nil;
    XCTAssertFalse( self.voteType.hasValidTrackingData );
}

@end
