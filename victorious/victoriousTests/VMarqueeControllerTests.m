//
//  VMarqueeControllerTests.m
//  victorious
//
//  Created by Will Long on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "VFullscreenMarqueeController.h"
#import "VTimerManager.h"
#import "VStreamCollectionViewDataSource.h"

@interface VMarqueeControllerTests : XCTestCase

@property (nonatomic, strong) VFullscreenMarqueeController *marquee;

@end

@implementation VMarqueeControllerTests

- (void)setUp
{
    [super setUp];
    self.marquee = [[VFullscreenMarqueeController alloc] initWithStream:nil];
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
    XCTAssert(self.marquee.autoScrollTimerManager, @"There should be a timer in the autoScrollTimer property after calling enableTimer");
    XCTAssert([self.marquee.autoScrollTimerManager isValid], @"The timer should be valid after it is enabled");
}

- (void)testDisableTimer
{
    [self.marquee enableTimer];
    [self.marquee disableTimer];
    XCTAssert(![self.marquee.autoScrollTimerManager isValid], @"The timer should be invalid after it is disabled.");
}

- (void)testSetCollectionView
{
    id collectionView = [OCMockObject niceMockForClass:[UICollectionView class]];
    [(UICollectionView *)[collectionView expect] setDelegate:self.marquee];
    [(UICollectionView *)[collectionView expect] setDataSource:self.marquee.streamDataSource];
    self.marquee.collectionView = collectionView;
    XCTAssert([self.marquee.collectionView isEqual:collectionView], @"The collection view was not set on VMarqueeController.");
    XCTAssert([self.marquee.streamDataSource.collectionView isEqual:collectionView], @"The collection view was not set on VStreamCollectionViewDataSource.");
    [collectionView verify];
}

@end
