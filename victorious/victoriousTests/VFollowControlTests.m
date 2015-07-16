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

- (void)testSettingControlState
{
    self.followControl.controlState = VFollowControlStateFollowed;
    XCTAssert(self.followControl.controlState == VFollowControlStateFollowed);
    
    self.followControl.controlState = VFollowControlStateUnfollowed;
    XCTAssert(self.followControl.controlState == VFollowControlStateUnfollowed);
    
    self.followControl.controlState = VFollowControlStateLoading;
    XCTAssert(self.followControl.controlState == VFollowControlStateLoading);
}

- (void)testSettingFollowStateAnimated
{
    [self.followControl setControlState:VFollowControlStateFollowed
                               animated:YES];
    XCTAssert(self.followControl.controlState == VFollowControlStateFollowed);
    
    [self.followControl setControlState:VFollowControlStateFollowed
                               animated:NO];
    XCTAssert(self.followControl.controlState == VFollowControlStateFollowed);
    
    [self.followControl setControlState:VFollowControlStateUnfollowed
                               animated:YES];
    XCTAssert(self.followControl.controlState == VFollowControlStateUnfollowed);
    
    [self.followControl setControlState:VFollowControlStateUnfollowed
                               animated:NO];
    XCTAssert(self.followControl.controlState == VFollowControlStateUnfollowed);
    
    [self.followControl setControlState:VFollowControlStateLoading
                               animated:YES];
    XCTAssert(self.followControl.controlState == VFollowControlStateLoading);
    
    [self.followControl setControlState:VFollowControlStateLoading
                               animated:NO];
    XCTAssert(self.followControl.controlState == VFollowControlStateLoading);
}

@end
