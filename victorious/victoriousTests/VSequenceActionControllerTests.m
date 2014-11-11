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
    self.sequenceActionController = [[VSequenceActionController alloc] init];
    self.userProfileViewController = [[VUserProfileViewController alloc] init];
    self.viewController = [[UIViewController alloc] init];
    
    self.sequence = [VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    self.sequence.user = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
    
    self.origImp = [VUserProfileViewController v_swizzleClassMethod:@selector(userProfileWithUser:) withBlock:^VUserProfileViewController *(VUser *user)
                    {
                        return [[VUserProfileViewController alloc] init];
                    }];
    self.origImpProfile = [VUserProfileViewController v_swizzleMethod:@selector(profile) withBlock:^VUser *
                           {
                               return self.sequence.user;
                           }];
}

- (void)tearDown
{
    [super tearDown];
    
    [VUserProfileViewController v_restoreOriginalImplementation:self.origImp forClassMethod:@selector(userProfileWithUser:)];
    [VUserProfileViewController v_restoreOriginalImplementation:self.origImpProfile forMethod:@selector(profile)];
}

- (void)testShowPosterProfileFromViewController
{
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssert( [self.sequenceActionController showPosterProfileFromViewController:self.viewController sequence:self.sequence] );
}

- (void)testShowPosterProfileFromViewControllerWithParent
{
    [self.navigationController pushViewController:self.userProfileViewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:self.viewController sequence:self.sequence] );
}

- (void)testShowPosterProfileFromViewControllerFail
{
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:nil sequence:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:self.viewController sequence:nil] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:self.viewController sequence:self.sequence] );
    
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:nil sequence:self.sequence] );
    
    [self.navigationController pushViewController:self.viewController animated:NO];
    XCTAssertFalse( [self.sequenceActionController showPosterProfileFromViewController:self.viewController sequence:nil] );
}

@end
