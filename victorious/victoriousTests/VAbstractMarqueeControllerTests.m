//
//  VAbstractMarqueeControllerTests.m
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
#import "VDependencyManager.h"
#import "VObjectManager.h"
#import "VDependencyManager+VObjectManager.h"
#import "VUploadManager.h"

@interface VAbstractMarqueeControllerTests : XCTestCase

@property (nonatomic, strong) VAbstractMarqueeController *marquee;

@end

@implementation VAbstractMarqueeControllerTests

- (void)setUp
{
    [super setUp];
    
    //Setup a dependencyManager with a valid objectManager to allow the marquee to fetch a stream during init
    [VObjectManager setupObjectManagerWithUploadManager:[VUploadManager sharedManager]];
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:
                                             @{
                                               @"marqueeURL" : @"http://dev.getvictorious.com/api/sequence/detail_list_by_stream/marquee/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                                               @"objectManager" : [VObjectManager sharedManager]
                                               }
                                                            dictionaryOfClassesByTemplateName:nil];
    self.marquee = [[VAbstractMarqueeController alloc] initWithDependencyManager:dependencyManager];
}

- (void)tearDown
{
    self.marquee = nil;
    [super tearDown];
}

- (void)testInit
{
    XCTAssertNoThrow([[VAbstractMarqueeController alloc] initWithDependencyManager:nil], @"abstractMarqueeController should not throw an exception when inited with a nil dependencyManager");
    VDependencyManager *noStreamDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
    XCTAssertNoThrow([[VAbstractMarqueeController alloc] initWithDependencyManager:noStreamDependencyManager], @"abstractMarqueeController should not throw an exception when inited with a dependencyManager with no marquee URL");
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

@end
