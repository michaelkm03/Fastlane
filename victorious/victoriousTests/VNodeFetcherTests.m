//
//  VNodeFetcherTests.m
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

#import "VDummyModels.h"

@interface VNodeFetcherTests : XCTestCase

@property (nonatomic, strong) VNode *videoNode;
@property (nonatomic, strong) VNode *imageNode;

@end

@implementation VNodeFetcherTests

- (void)setUp
{
    self.videoNode = [VDummyModels objectWithEntityName:@"Node"
                                               subclass:[VNode class]];
    VAsset *liveStreamAsset = [VDummyModels objectWithEntityName:@"Asset"
                                                        subclass:[VAsset class]];
    liveStreamAsset.mime_type = @"application/x-mpegURL";
    
    VAsset *mp4Asset = [VDummyModels objectWithEntityName:@"Asset"
                                                 subclass:[VAsset class]];
    mp4Asset.mime_type = @"video/mp4";
    
    self.videoNode.assets = [NSOrderedSet orderedSetWithArray:@[liveStreamAsset, mp4Asset]];
    [[self.videoNode managedObjectContext] save:nil];
    
    self.imageNode = [VDummyModels objectWithEntityName:@"Node"
                                               subclass:[VNode class]];
    VAsset *imageAsset = [VDummyModels objectWithEntityName:@"Asset"
                                                   subclass:[VAsset class]];
    imageAsset.data = @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/d5be0a1738ffe96a3169aeee701481f3/original.jpg";
    self.imageNode.assets = [NSOrderedSet orderedSetWithArray:@[imageAsset]];
    [[self.imageNode managedObjectContext] save:nil];
}

- (void)testIdentifyVideoMimeTypes
{
    XCTAssertNotNil([self.videoNode httpLiveStreamingAsset]);
    XCTAssertNotNil([self.videoNode mp4Asset]);
    XCTAssertNil([self.videoNode imageAsset]);
}

- (void)testBadMimeTypes
{
    VAsset *badMimeTypeAsset = [VDummyModels objectWithEntityName:@"Asset"
                                                        subclass:[VAsset class]];
    badMimeTypeAsset.mime_type = nil;

    self.videoNode.assets = [NSOrderedSet orderedSetWithArray:@[badMimeTypeAsset]];
    [[self.videoNode managedObjectContext] save:nil];
    
    XCTAssertNil([self.videoNode mp4Asset]);
    XCTAssertNil([self.videoNode httpLiveStreamingAsset]);
    
    badMimeTypeAsset.mime_type = @"blah blah blah";
    [[self.videoNode managedObjectContext] save:nil];
    
    XCTAssertNil([self.videoNode mp4Asset]);
    XCTAssertNil([self.videoNode httpLiveStreamingAsset]);
    
    self.videoNode.assets = nil;
    [[self.videoNode managedObjectContext] save:nil];
    
    XCTAssertNil([self.videoNode mp4Asset]);
}

- (void)testIdentifyImageAsset
{
    XCTAssertNotNil([self.imageNode imageAsset]);
    XCTAssertNil([self.videoNode imageAsset]);
}

@end
