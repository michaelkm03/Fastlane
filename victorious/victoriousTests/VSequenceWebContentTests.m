//
//  VSequenceWebContentTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;
@import XCTest;

#import "VDummyModels.h"
#import "VSequence+Fetcher.h"
#import "VConstants.h"
#import "VNode.h"
#import "VAsset.h"

@interface VSequenceWebContentTests : XCTestCase

@end

@implementation VSequenceWebContentTests

- (void)testSequenceWebContent
{
    VSequence *sequence = (VSequence *)[VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    
    XCTAssertFalse( [sequence isOwnerContent] );
    XCTAssertFalse( [sequence isAnnouncement] );
    sequence.category = kVOwnerAnnouncementCategory;
    XCTAssert( [sequence isOwnerContent] );
    XCTAssert( [sequence isAnnouncement] );
    
    XCTAssertFalse( [sequence isPreviewWebContent] );
    XCTAssertNil( [sequence webContentPreviewUrl] );
    sequence.previewType = kVAssetTypeURL;
    sequence.previewData = @"http://www.getvictorious.com/preview";
    XCTAssert( [sequence isPreviewWebContent] );
    XCTAssertEqualObjects( [sequence webContentPreviewUrl], sequence.previewData );
    
    XCTAssertFalse( [sequence isWebContent] );
    XCTAssertNil( [sequence webContentUrl] );
    VNode *node = (VNode *)[VDummyModels objectWithEntityName:@"Node" subclass:[VNode class]];
    VAsset *asset = (VAsset *)[VDummyModels objectWithEntityName:@"Asset" subclass:[VAsset class]];
    asset.type = kVAssetTypeURL;
    asset.data = @"http://www.getvictorious.com";
    node.assets = [[NSOrderedSet alloc] initWithObject:asset];
    sequence.nodes = [[NSOrderedSet alloc] initWithObject:node];
    XCTAssert( [sequence isWebContent] );
    XCTAssertEqualObjects( [sequence webContentUrl], asset.data );
}

@end
