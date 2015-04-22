//
//  VMessageViewControllerFactoryTests.m
//  victorious
//
//  Created by Josh Hinman on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "OCMock.h"
#import "VDependencyManager.h"
#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"
#import "VMessageViewControllerFactory.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VUser.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VUser (UnitTesting)

@end

@implementation VUser (UnitTesting)

- (NSNumber *)remoteId // add a concrete implementation of CoreData's dynamic property for OCMock's purposes
{
    return nil;
}

@end

#pragma mark -

@interface VMessageViewControllerFactoryTests : XCTestCase

@property (nonatomic, strong) id mockDependencyManager;
@property (nonatomic, strong) id mockUnreadMessageCountCoordinator;
@property (nonatomic, strong) VMessageViewControllerFactory *factory;

@end

@implementation VMessageViewControllerFactoryTests

- (void)setUp
{
    [super setUp];
    self.mockDependencyManager = [OCMockObject niceMockForClass:[VDependencyManager class]];
    self.mockUnreadMessageCountCoordinator = [OCMockObject niceMockForClass:[VUnreadMessageCountCoordinator class]];
    self.factory = [[VMessageViewControllerFactory alloc] initWithDependencyManager:self.mockDependencyManager];
    self.factory.unreadMessageCountCoordinator = self.mockUnreadMessageCountCoordinator;
}

- (void)testFactoryMethod
{
    id mockUser = [OCMockObject niceMockForClass:[VUser class]];
    [[[mockUser stub] andReturn:@(12)] remoteId];

    VMessageContainerViewController *messageViewController = [self.factory messageViewControllerForUser:mockUser];
    XCTAssert([messageViewController isKindOfClass:[VMessageContainerViewController class]]);
    XCTAssertEqual(messageViewController.messageCountCoordinator, self.mockUnreadMessageCountCoordinator);
    XCTAssert([(VMessageViewController *)messageViewController.conversationTableViewController shouldRefreshOnAppearance]);
}

- (void)testSameMessageViewReturnedAgain
{
    id mockUser = [OCMockObject niceMockForClass:[VUser class]];
    [[[mockUser stub] andReturn:@(12)] remoteId];
    
    VMessageContainerViewController *messageViewController = [self.factory messageViewControllerForUser:mockUser];
    XCTAssertNotNil(messageViewController);
    
    VMessageContainerViewController *otherMessageViewController = [self.factory messageViewControllerForUser:mockUser];
    XCTAssertNotNil(otherMessageViewController);
    XCTAssertEqual(messageViewController, otherMessageViewController);
}

- (void)testMessageViewsAreNotSharedBetweenFactoryInstances
{
    // The implementation of VMessageViewControllerFactory shouldn't use any static tricks--different factories should return different instances
    
    id mockUser = [OCMockObject niceMockForClass:[VUser class]];
    [[[mockUser stub] andReturn:@(12)] remoteId];
    
    VMessageContainerViewController *messageViewController = [self.factory messageViewControllerForUser:mockUser];
    XCTAssertNotNil(messageViewController);
    
    VMessageViewControllerFactory *factory = [[VMessageViewControllerFactory alloc] initWithDependencyManager:self.mockDependencyManager];
    factory.unreadMessageCountCoordinator = self.mockUnreadMessageCountCoordinator;
    
    VMessageContainerViewController *otherMessageViewController = [factory messageViewControllerForUser:mockUser];
    XCTAssertNotNil(otherMessageViewController);
    XCTAssertNotEqual(messageViewController, otherMessageViewController);
}

@end
