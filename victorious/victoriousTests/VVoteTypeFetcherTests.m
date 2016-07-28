//
//  VVoteTypeFetcherTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDummyModels.h"
#import "VVoteType.h"

// TODO
#if 0

@interface VVoteTypeFetcherTests : XCTestCase

@property (nonatomic, strong) VVoteType *voteType;

@end

@implementation VVoteTypeFetcherTests

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

        NSString *number = [NSString stringWithFormat:@"0000%lu", (unsigned long)idx];
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

- (void)testContentMode
{
    VVoteType *voteType = (VVoteType *)[VDummyModels objectWithEntityName:@"VoteType" subclass:[VVoteType class]];
    
    voteType.imageContentMode = @"scaleaspectfill";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleAspectFill );
    
    voteType.imageContentMode = @"scaletofill";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleToFill );
    
    voteType.imageContentMode = @"scaleaspectfit";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleAspectFit );
    
    voteType.imageContentMode = @"scaleaspectfill";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleAspectFill );
    
    voteType.imageContentMode = @"redraw";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeRedraw );
    
    voteType.imageContentMode = @"center";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeCenter );
    
    voteType.imageContentMode = @"top";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeTop );
    
    voteType.imageContentMode = @"bottom";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeBottom );
    
    voteType.imageContentMode = @"left";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeLeft );
    
    voteType.imageContentMode = @"right";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeRight );
    
    voteType.imageContentMode = @"topleft";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeTopLeft );
    
    voteType.imageContentMode = @"topright";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeTopRight );
    
    voteType.imageContentMode = @"bottomleft";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeBottomLeft );
    
    voteType.imageContentMode = @"bottomright";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeBottomRight );
    
    voteType.imageContentMode = nil;
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleAspectFill );
    
    voteType.imageContentMode = @"";
    XCTAssertEqual( voteType.contentMode, UIViewContentModeScaleAspectFill );
}

@end

#endif
