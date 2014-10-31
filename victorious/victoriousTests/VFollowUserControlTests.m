//
//  VFollowUserControlTests.m
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VFollowUserControl.h"

@interface VFollowUserControlTests : XCTestCase

@property (nonatomic, strong) VFollowUserControl *followerUserControl;

@end

@implementation VFollowUserControlTests

- (void)setUp
{
    [super setUp];

    self.followerUserControl = [[VFollowUserControl alloc] initWithFrame:CGRectZero];
}

- (void)testExample
{
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testSettingFollowState
{
    self.followerUserControl.following = YES;
    XCTAssert(self.followerUserControl.following == YES);
    
    self.followerUserControl.following = NO;
    XCTAssert(self.followerUserControl.following == NO);
}

- (void)testSettingFollowStateAnimated
{
    [self.followerUserControl setFollowing:YES
                                  animated:YES];
    XCTAssert(self.followerUserControl.following == YES);
    
    [self.followerUserControl setFollowing:NO
                                  animated:YES];
    XCTAssert(self.followerUserControl.following == NO);
    
    [self.followerUserControl setFollowing:YES
                                  animated:NO];
    XCTAssert(self.followerUserControl.following == YES);
    
    [self.followerUserControl setFollowing:NO
                                  animated:NO];
    XCTAssert(self.followerUserControl.following == NO);
}

@end
