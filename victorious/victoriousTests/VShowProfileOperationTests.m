//
//  VShowProfileOperationTests.m
//  victorious
//
//  Created by Vincent Ho on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VDependencyManager.h"
#import "VDummyModels.h"
#import "VSequence.h"

#import "victorious-Swift.h"

#define USER_ID 12345
#define OTHER_USER_ID 54321

@interface VShowProfileOperationTests : XCTestCase

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) IMP origImp;

@end

@implementation VShowProfileOperationTests

- (void)setUp
{
    [super setUp];
    self.navigationController = [[UINavigationController alloc] init];
    self.viewController = [[UIViewController alloc] init];
    [self.navigationController setViewControllers:@[self.viewController] animated:NO];
    self.sequence = [VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    VUser *sequenceUser = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
    sequenceUser.remoteId = @(USER_ID);
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                 configuration:nil
                                             dictionaryOfClassesByTemplateName:nil];
    
    self.origImp = [VDependencyManager v_swizzleMethod:@selector(userProfileViewControllerWithRemoteID:)
                                             withBlock:^VUserProfileViewController *(VDependencyManager *dependencyManager, NSNumber *userID)
                    {
                        VUserProfileViewController *profileVC = [[VUserProfileViewController alloc] init];
                        profileVC.dependencyManager = self.dependencyManager;
                        VUser *user = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
                        user.remoteId = userID;
                        profileVC.user = user;
                        return profileVC;
                    }];
}

- (void)tearDown
{
    [super tearDown];
    [VDependencyManager v_restoreOriginalImplementation:self.origImp
                                              forMethod:@selector(userProfileViewControllerWithRemoteID:)];
}

- (void)testNotOnProfile
{
    ShowProfileOperation *operation = [[ShowProfileOperation alloc] initWithOriginViewController:self.viewController
                                                                               dependencyManager:self.dependencyManager
                                                                                          userId:USER_ID];
    
    [operation queueWithCompletion:^(NSError *error, BOOL cancelled)
     {
         UIViewController *topVC = self.navigationController.topViewController;
         XCTAssert([topVC isKindOfClass:[VUserProfileViewController class]]);
         
         VUserProfileViewController *topProfileVC = (VUserProfileViewController *)topVC;
         
         // Make sure that we didn't change to another profile
         XCTAssert(topProfileVC.user.remoteId.integerValue == USER_ID);
         
         [topProfileVC dismissViewControllerAnimated:NO completion:^
         {
             XCTAssert([self.navigationController.viewControllers isEqualToArray:@[self.viewController]]);
         }];
     }];
}

- (void)testOnOtherUserProfile
{
    UIViewController *otherProfileViewController = [self.dependencyManager userProfileViewControllerWithRemoteID:@(OTHER_USER_ID)];
    [self.navigationController pushViewController:otherProfileViewController animated:NO];
    
    ShowProfileOperation *operation = [[ShowProfileOperation alloc] initWithOriginViewController:otherProfileViewController
                                                                               dependencyManager:self.dependencyManager
                                                                                          userId:USER_ID];
    
    NSArray *expectedViewControllers = @[self.viewController, otherProfileViewController];
    [operation queueWithCompletion:^(NSError *error, BOOL cancelled)
     {
         UIViewController *topVC = self.navigationController.topViewController;
         XCTAssert([topVC isKindOfClass:[VUserProfileViewController class]]);
         
         VUserProfileViewController *topProfileVC = (VUserProfileViewController *)topVC;
         
         // Make sure that we changed to the new profile
         XCTAssert(topProfileVC.user.remoteId.integerValue == USER_ID);
         
         [topProfileVC dismissViewControllerAnimated:NO completion:^
         {
             XCTAssert([self.navigationController.viewControllers isEqualToArray:expectedViewControllers]);
         }];
     }];
}

- (void)testOnCurrentUserProfile
{
    UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteID:@(USER_ID)];
    [self.navigationController pushViewController:profileViewController animated:NO];
    
    ShowProfileOperation *operation = [[ShowProfileOperation alloc] initWithOriginViewController:profileViewController
                                                                               dependencyManager:self.dependencyManager
                                                                                          userId:USER_ID];

    NSArray *expectedViewControllers = @[self.viewController, profileViewController];
    [operation queueWithCompletion:^(NSError *error, BOOL cancelled)
     {
         // Make sure that we didn't change
         XCTAssert([self.navigationController.viewControllers isEqualToArray:expectedViewControllers]);
     }];
}

@end
