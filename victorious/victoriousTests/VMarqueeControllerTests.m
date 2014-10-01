//
//  VMarqueeControllerTests.m
//  victorious
//
//  Created by Will Long on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VMarqueeController.h"

@interface VMarqueeControllerTests : XCTestCase

@property (nonatomic, strong) VMarqueeController *marquee;

@end


//@property (nonatomic, weak) id<VMarqueeDelegate> delegate;
//@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
//@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
//@property (strong, nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
//@property (weak, nonatomic) UICollectionView *collectionView;///<The colletion view used to display the streamItems
//@property (weak, nonatomic) VMarqueeTabIndicatorView *tabView;///<The Marquee tab view to update
//@property (nonatomic, readonly) NSTimer *autoScrollTimer;///<The timer in control of auto scroll
//
//- (void)disableTimer;
//- (void)enableTimer;

@implementation VMarqueeControllerTests

- (void)setUp
{
    [super setUp];
    self.marquee = [[VMarqueeController alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEnableTimer
{
    [self.marquee enableTimer];
    XCTAssert(self.marquee.autoScrollTimer, @"There should be a timer in the autoScrollTimer property after calling enableTimer");
    XCTAssert(self.marquee.autoScrollTimer.isValid, @"The timer should be valid");
}

- (void)testDisableTimer
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
