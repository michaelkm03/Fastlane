//
//  VSuggestedPeopleTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDiscoverSuggestedPeopleViewController.h"
#import "VDummyModels.h"
#import "NSObject+VMethodSwizzling.h"

@interface VDiscoverSuggestedPeopleViewController (UnitTest)

- (NSArray *)usersByRemovingUser:(VUser *)user fromUsers:(NSArray *)users;
- (void)reload;
- (void)didLoadWithUsers:(NSArray *)users;

@end

@interface VSuggestedPeopleTests : XCTestCase

@property (nonatomic, strong) VUser *userNotPresent;
@property (nonatomic, strong) VUser *userToRemove;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) VDiscoverSuggestedPeopleViewController *viewController;
@property (nonatomic, assign) NSUInteger startCount;

@end

@implementation VSuggestedPeopleTests

- (void)setUp
{
    [super setUp];
    
    self.viewController = [VDiscoverSuggestedPeopleViewController instantiateFromStoryboard:@"Discover"];
    
    self.startCount = 10;
    self.users = [VDummyModels createUsers:self.startCount];
    self.userToRemove = self.users.firstObject;
    self.userNotPresent = [VDummyModels createUsers:1].firstObject;
}

- (void)testRefresh
{
    IMP imp = [VDiscoverSuggestedPeopleViewController v_swizzleMethod:@selector(reload) withBlock:^{}];
    
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
    
    [VDiscoverSuggestedPeopleViewController v_restoreOriginalImplementation:imp forMethod:@selector(reload)];
}

@end
