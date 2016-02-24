//
//  VSequenceActionControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VSequenceActionController.h"
#import "VUserProfileViewController.h"
#import "VDummyModels.h"
#import "VSequence.h"
#import "VUser.h"
#import "NSObject+VMethodSwizzling.h"
#import "VDependencyManager+VUserProfile.h"

@interface VSequenceActionControllerTests : XCTestCase

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) VSequenceActionController *sequenceActionController;
@property (nonatomic, strong) VUserProfileViewController *userProfileViewController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, assign) IMP origImp;
@property (nonatomic, assign) IMP origImpProfile;

@end

@implementation VSequenceActionControllerTests

- (void)setUp
{
    [super setUp];
    
    self.navigationController = [[UINavigationController alloc] init];
    self.userProfileViewController = [[VUserProfileViewController alloc] init];
    self.viewController = [[UIViewController alloc] init];
    self.sequenceActionController = [[VSequenceActionController alloc] initWithDepencencyManager:nil andOriginViewController:self.viewController];
    
    self.sequence = [VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.user = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
    
    self.origImp = [VUserProfileViewController v_swizzleClassMethod:@selector(userProfileViewControllerWithUser:) withBlock:^VUserProfileViewController *(VUser *user)
                    {
                        return [[VUserProfileViewController alloc] init];
                    }];
    self.origImpProfile = [VUserProfileViewController v_swizzleMethod:@selector(user) withBlock:^VUser *
                           {
                               return self.sequence.user;
                           }];
}

- (void)tearDown
{
    [super tearDown];
    
    [VUserProfileViewController v_restoreOriginalImplementation:self.origImp forClassMethod:@selector(userProfileViewControllerWithUser:)];
    [VUserProfileViewController v_restoreOriginalImplementation:self.origImpProfile forMethod:@selector(user)];
}

- (void)testShowPosterProfileFromViewController
{
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssert( [self.sequenceActionController showPosterProfileWithSequence:self.sequence] );
}

- (void)testShowPosterProfileFromViewControllerWithParent
{
    [self.navigationController pushViewController:self.userProfileViewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:self.sequence] );
}

- (void)testShowPosterProfileFromViewControllerFail
{
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:self.sequence] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:self.sequence] );
    
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showPosterProfileWithSequence:nil] );
}

- (void)testShowProfileFromViewController
{
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssert( [self.sequenceActionController showProfile:self.sequence.user] );
}

- (void)testShowProfileFromViewControllerWithParent
{
    [self.navigationController pushViewController:self.userProfileViewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showProfile:self.sequence.user] );
}

- (void)testShowProfileFromViewControllerFail
{
    XCTAssertFalse( [self.sequenceActionController showProfile:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showProfile:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showProfile:self.sequence.user] );
    
    XCTAssertFalse( [self.sequenceActionController showProfile:self.sequence.user] );
    
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showProfile:nil] );
}

@end
