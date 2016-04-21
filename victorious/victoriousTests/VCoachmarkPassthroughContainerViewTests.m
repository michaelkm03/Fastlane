//
//  VCoachmarkPassthroughContainerViewTests.m
//  victorious
//
//  Created by Sharif Ahmed on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VCoachmarkPassthroughContainerView.h"
#import "VCoachmarkView.h"
#import <OCMock/OCMock.h>

@interface VCoachmarkPassthroughContainerViewTests : XCTestCase

@property (nonatomic, strong) VCoachmarkView *coachmarkView;
@property (nonatomic, assign) CGRect coachmarkPassthroughContainerViewFrame;
@property (nonatomic, strong) id <VPassthroughContainerViewDelegate> mockDelegate;

@end

@implementation VCoachmarkPassthroughContainerViewTests

- (void)setUp
{
    [super setUp];
    self.coachmarkView = [[VCoachmarkView alloc] init];
    self.coachmarkPassthroughContainerViewFrame = CGRectMake(10, 20, 30, 40);
    self.mockDelegate = [OCMockObject niceMockForProtocol:@protocol(VPassthroughContainerViewDelegate)];
}

- (void)tearDown
{
    self.coachmarkView = nil;
    [super tearDown];
}

- (void)testClassInit
{
    VCoachmarkPassthroughContainerView *coachmarkPassthroughContainerView = [VCoachmarkPassthroughContainerView coachmarkPassthroughContainerViewWithCoachmarkView:self.coachmarkView
                                                                                                                                                       andDelegate:self.mockDelegate];
    coachmarkPassthroughContainerView.frame = self.coachmarkPassthroughContainerViewFrame;
    XCTAssert(CGRectEqualToRect(coachmarkPassthroughContainerView.frame, self.coachmarkPassthroughContainerViewFrame), @"The coachmark passthough container view's frame should be equivalent to the one provided via the class init");
    XCTAssertEqual(coachmarkPassthroughContainerView.delegate, self.mockDelegate, @"The coachmark passthough container view's delegate should be equivalent to the one provided via the class init");
    XCTAssertEqual(self.coachmarkView, coachmarkPassthroughContainerView.coachmarkView, @"The coachmark passthough container view's coachmark view should be equivalent to the one provided via the class init");
}

- (void)testClassInitBadParams
{
    XCTAssertThrows([VCoachmarkPassthroughContainerView coachmarkPassthroughContainerViewWithCoachmarkView:nil
                                                                                               andDelegate:self.mockDelegate], @"The coachmark passthrough container view's class init method should assert that the provided coachmark view be non-nil");
    XCTAssertNoThrow([VCoachmarkPassthroughContainerView coachmarkPassthroughContainerViewWithCoachmarkView:self.coachmarkView
                                                                                                andDelegate:nil], @"The coachmark passthrough container view's class init method should not throw an exception if the provided delegate is nil");
}

#pragma mark - Silencing compiler warnings

- (void)passthroughViewRecievedTouch:(VPassthroughContainerView *)passthroughContainerView
{
    XCTAssert([passthroughContainerView isKindOfClass:[VCoachmarkPassthroughContainerView class]]);
}

@end
