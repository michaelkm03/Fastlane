//
//  VSuggestedPeopleTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VSuggestedPeopleCollectionViewController.h"
#import "VDummyModels.h"
#import "NSObject+VMethodSwizzling.h"

@interface VSuggestedPeopleCollectionViewController (UnitTest)

- (NSArray *)usersByRemovingUser:(VUser *)user fromUsers:(NSArray *)users;
- (void)reload;
- (void)didLoadWithUsers:(NSArray *)users;

@end

@interface VSuggestedPeopleTests : XCTestCase

@property (nonatomic, strong) VUser *userNotPresent;
@property (nonatomic, strong) VUser *userToRemove;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *viewController;
@property (nonatomic, assign) NSUInteger startCount;

@end

@implementation VSuggestedPeopleTests

- (void)setUp
{
    [super setUp];
    
    self.viewController = [VSuggestedPeopleCollectionViewController instantiateFromStoryboard:@"Discover"];
    
    self.startCount = 10;
    self.users = [VDummyModels createUsers:self.startCount];
    self.userToRemove = self.users.firstObject;
    self.userNotPresent = [VDummyModels createUsers:1].firstObject;
}

- (void)testRemoveUser
{
    NSArray *updatedUsers = [self.viewController usersByRemovingUser:self.userToRemove fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount - 1 );
    
    updatedUsers = [self.viewController usersByRemovingUser:self.userToRemove fromUsers:self.users];
    // Once removed, the array should return unchanged
    XCTAssertEqual( updatedUsers.count, self.startCount - 1 );
}

- (void)testRemoveUserNotPresent
{
    NSArray *updatedUsers = [self.viewController usersByRemovingUser:self.userNotPresent fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount );
}

- (void)testInvalidInput
{
    NSArray *updatedUsers = [self.viewController usersByRemovingUser:nil fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount );
    
    updatedUsers = [self.viewController usersByRemovingUser:self.userToRemove fromUsers:nil];
    XCTAssertNil( updatedUsers );
    
    updatedUsers = [self.viewController usersByRemovingUser:self.userToRemove fromUsers:@[]];
    XCTAssertEqual( updatedUsers.count, (NSUInteger)0 );
}

- (void)testRefresh
{
    IMP imp = [VSuggestedPeopleCollectionViewController v_swizzleMethod:@selector(reload) withBlock:^{}];
    
    NSUInteger count = 5;
    
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    
    [self.viewController refresh:YES];
    [self.viewController didLoadWithUsers:[VDummyModels createUsers:count]]; // Simulates successful reload response
    XCTAssert( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.suggestedUsers.count, count );
    
    [self.viewController refresh:NO];
    XCTAssert( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.suggestedUsers.count, count );
    
    [self.viewController refresh:YES];
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.suggestedUsers.count, (NSUInteger)0 );
    
    [VSuggestedPeopleCollectionViewController v_restoreOriginalImplementation:imp forMethod:@selector(reload)];
}

@end
