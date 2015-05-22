//
//  VCoachmarkViewTests.m
//  victorious
//
//  Created by Sharif Ahmed on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VCoachmarkView.h"
#import "VCoachmark.h"

@interface VCoachmarkViewTests : XCTestCase

@property (nonatomic, strong) VCoachmark *coachmark;
@property (nonatomic, assign) CGFloat coachmarkWidth;
@property (nonatomic, assign) CGFloat arrowHorizontalOffset;
@property (nonatomic, assign) VTooltipArrowDirection arrowDirection;

@end

@implementation VCoachmarkViewTests

- (void)setUp
{
    [super setUp];
    self.coachmark = [[VCoachmark alloc] init];
}

- (void)tearDown
{
    self.coachmark = nil;
    [super tearDown];
}

- (void)testToastCoachmark
{
    VCoachmarkView *coachmarkView = [VCoachmarkView toastCoachmarkViewWithCoachmark:self.coachmark
                                                                           andWidth:self.coachmarkWidth];
    XCTAssertEqual(self.coachmark, coachmarkView.coachmark, @"The coachmark of the coachmark view should be the coachmark provided in toastCoachmarkViewWithCoachmark:andWidth:");
    XCTAssertEqual(self.coachmarkWidth, CGRectGetWidth(coachmarkView.frame), @"The width of the coachmark view should be the width provided in toastCoachmarkViewWithCoachmark:andWidth:");
    XCTAssertEqual(VTooltipArrowDirectionInvalid, coachmarkView.arrowDirection, @"The arrow direction of the coachmark view should be invalid on the coachmark view returned from toastCoachmarkViewWithCoachmark:andWidth:");
}

- (void)testToastCoachmarkBadInitParams
{
    XCTAssertThrows([VCoachmarkView toastCoachmarkViewWithCoachmark:nil
                                                           andWidth:self.coachmarkWidth],
                    @"toastCoachmarkViewWithCoachmark:andWidth: should throw an exception if a nil coachmark is provided");
    
    XCTAssertNoThrow([VCoachmarkView toastCoachmarkViewWithCoachmark:self.coachmark
                                                            andWidth:0],
                     @"toastCoachmarkViewWithCoachmark:andWidth: should not throw an exception if a 0 width is specified");
}

- (void)testTooltipCoachmark
{
    VCoachmarkView *coachmarkView = [VCoachmarkView tooltipCoachmarkViewWithCoachmark:self.coachmark
                                                                                width:self.coachmarkWidth
                                                                arrowHorizontalOffset:self.arrowHorizontalOffset
                                                                    andArrowDirection:self.arrowDirection];
    XCTAssertEqual(self.coachmark, coachmarkView.coachmark, @"The coachmark of the coachmark view should be the coachmark provided in tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection:");
    XCTAssertEqual(self.coachmarkWidth, CGRectGetWidth(coachmarkView.frame), @"The width of the coachmark view should be the width provided in tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection:");
    XCTAssertEqual(self.arrowDirection, coachmarkView.arrowDirection, @"The arrow direction of the coachmark view should be the arrow direction provided in tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection:");
}

- (void)testTooltipCoachmarkBadInitParams
{
    XCTAssertThrows([VCoachmarkView tooltipCoachmarkViewWithCoachmark:nil
                                                                width:self.coachmarkWidth
                                                arrowHorizontalOffset:self.arrowHorizontalOffset
                                                    andArrowDirection:self.arrowDirection],
                    @"tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection: should throw an exception if a nil coachmark is provided");
    XCTAssertNoThrow([VCoachmarkView tooltipCoachmarkViewWithCoachmark:self.coachmark
                                                                width:-40.0f
                                                arrowHorizontalOffset:self.arrowHorizontalOffset
                                                    andArrowDirection:self.arrowDirection],
                    @"tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection: should not throw an exception if the provided width is invalid");
    XCTAssertNoThrow([VCoachmarkView tooltipCoachmarkViewWithCoachmark:self.coachmark
                                                                width:self.coachmarkWidth
                                                arrowHorizontalOffset:-40.0f
                                                    andArrowDirection:self.arrowDirection],
                    @"tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection: should not throw an exception if the provided arrowHorizontalOffset is offscreen");
    XCTAssertThrows([VCoachmarkView tooltipCoachmarkViewWithCoachmark:self.coachmark
                                                                width:self.coachmarkWidth
                                                arrowHorizontalOffset:self.arrowHorizontalOffset
                                                    andArrowDirection:VTooltipArrowDirectionInvalid],
                    @"tooltipCoachmarkViewWithCoachmark:width:arrowHorizontalOffset:andArrowDirection: should throw an exception if an invalid arrowDirection value is provided");
}

@end
