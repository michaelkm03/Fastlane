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

@interface VSuggestedPeopleCollectionViewController (UnitTest)

- (NSArray *)usersByRemovingUser:(VUser *)user fromUsers:(NSArray *)users;

@end

@interface VSuggestedPeopleTests : XCTestCase

@property (nonatomic, strong) VUser *userNotPresent;
@property (nonatomic, strong) VUser *userToRemove;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleCollectionViewController;
@property (nonatomic, assign) NSUInteger startCount;

@end

@implementation VSuggestedPeopleTests

- (void)setUp
{
    [super setUp];
    
    self.suggestedPeopleCollectionViewController = [[VSuggestedPeopleCollectionViewController alloc] init];
    
    self.startCount = 10;
    self.users = [VDummyModels createUsers:self.startCount];
    self.userToRemove = self.users.firstObject;
    self.userNotPresent = [VDummyModels createUsers:1].firstObject;
}

- (void)testRemoveUser
{
    NSArray *updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:self.userToRemove fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount - 1 );
    
    updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:self.userToRemove fromUsers:self.users];
    // Once removed, the array should return unchanged
    XCTAssertEqual( updatedUsers.count, self.startCount - 1 );
}

- (void)testRemoveUserNotPresent
{
    NSArray *updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:self.userNotPresent fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount );
}

- (void)testInvalidInput
{
    NSArray *updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:nil fromUsers:self.users];
    XCTAssertEqual( updatedUsers.count, self.startCount );
    
    updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:self.userToRemove fromUsers:nil];
    XCTAssertNil( updatedUsers );
    
    updatedUsers = [self.suggestedPeopleCollectionViewController usersByRemovingUser:self.userToRemove fromUsers:@[]];
    XCTAssertEqual( updatedUsers.count, (NSUInteger)0 );
}

@end
