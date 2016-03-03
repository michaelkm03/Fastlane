//
//  VToggleLikeSequenceOperationTests.m
//  victorious
//
//  Created by Vincent Ho on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDummyModels.h"
#import "VSequence.h"

#import "victorious-Swift.h"

@interface VToggleLikeSequenceOperationTests : XCTestCase

@property (nonatomic, strong) VSequence *sequence;

@end

@implementation VToggleLikeSequenceOperationTests

- (void)setupSequenceLiked:(BOOL)liked
{
    self.sequence = [VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.isLikedByMainUser = liked ? @(1) : @(0);
}

- (void)testInitiallyLiked
{
    [self setupSequenceLiked:YES];
    [[[ToggleLikeSequenceOperation alloc] initWithSequenceObjectId:self.sequence.objectID] queueWithCompletion:^(NSArray *results, NSError *error)
     {
         XCTAssertFalse(self.sequence.isLikedByMainUser.boolValue);
     }];
}

- (void)testNotInitiallyLiked
{
    [self setupSequenceLiked:NO];
    [[[ToggleLikeSequenceOperation alloc] initWithSequenceObjectId:self.sequence.objectID] queueWithCompletion:^(NSArray *results, NSError *error)
     {
         XCTAssert(self.sequence.isLikedByMainUser.boolValue);
     }];
}

@end
