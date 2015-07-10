//
//  VFollowControlTests.m
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VFollowControl.h"

@interface VFollowControlTests : XCTestCase

@property (nonatomic, strong) VFollowControl *followControl;

@end

@implementation VFollowControlTests

- (void)setUp
{
    [super setUp];

    self.followControl = [[VFollowControl alloc] initWithFrame:CGRectZero];
}

- (void)testSettingFollowState
{
    self.followControl.following = YES;
    XCTAssert(self.followControl.following == YES);
    
    self.followControl.following = NO;
    XCTAssert(self.followControl.following == NO);
}

- (void)testSettingFollowStateAnimated
{
    [self.followControl setFollowing:YES
                            animated:YES];
    XCTAssert(self.followControl.following == YES);
    
    [self.followControl setFollowing:NO
                            animated:YES];
    XCTAssert(self.followControl.following == NO);
    
    [self.followControl setFollowing:YES
                            animated:NO];
    XCTAssert(self.followControl.following == YES);
    
    [self.followControl setFollowing:NO
                            animated:NO];
    XCTAssert(self.followControl.following == NO);
}

@end
