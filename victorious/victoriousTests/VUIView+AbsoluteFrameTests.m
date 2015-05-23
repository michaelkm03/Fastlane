//
//  VUIView+AbsoluteFrameTests.m
//  victorious
//
//  Created by Sharif Ahmed on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "UIView+AbsoluteFrame.h"

@interface VUIView_AbsoluteFrameTests : XCTestCase

@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, assign) CGRect frame1;
@property (nonatomic, assign) CGRect frame2;

@end

@implementation VUIView_AbsoluteFrameTests

- (void)setUp
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    [[[UIApplication sharedApplication] delegate] setWindow:window];
    self.frame1 = CGRectMake(100, 20, 30, 200);
    self.frame2 = CGRectMake(300, 40, 50, 500);
    self.view1 = [[UIView alloc] initWithFrame:self.frame1];
    self.view2 = [[UIView alloc] initWithFrame:self.frame2];
    
    [self.view1 addSubview:self.view2];
    [window addSubview:self.view1];
}

- (void)tearDown
{
    self.view1 = nil;
    self.view2 = nil;
    [super tearDown];
}

- (void)testAbsoluteFrame
{
    CGRect frame = [self.view1 absoluteFrame];
    XCTAssert(CGRectEqualToRect(self.frame1, frame), @"The absolute frame of a view with no superview should be it's own frame");
    
    frame = [self.view2 absoluteFrame];
    CGRect compositeFrame = self.frame2;
    compositeFrame.origin.x += self.frame1.origin.x;
    compositeFrame.origin.y += self.frame1.origin.y;
    XCTAssert(CGRectEqualToRect(compositeFrame, frame), @"The absolute frame of a view with a superview should have the origin of its superview added to its own");
}

- (void)testAbsoluteOrigin
{
    CGRect frame = [self.view1 absoluteFrame];
    XCTAssert(CGPointEqualToPoint(self.frame1.origin, frame.origin), @"The absolute origin of a view with no superview should be it's own origin");
    
    frame = [self.view2 absoluteFrame];
    CGRect compositeFrame = self.frame2;
    compositeFrame.origin.x += self.frame1.origin.x;
    compositeFrame.origin.y += self.frame1.origin.y;
    XCTAssert(CGPointEqualToPoint(compositeFrame.origin, frame.origin), @"The absolute origin of a view with a superview should have the origin of its superview added to its own");
}

@end
