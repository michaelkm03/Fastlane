//
//  VAuthorizedActionTests.m
//  victorious
//
//  Created by Patrick Lynch on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VAuthorizedAction.h"
#import "VDependencyManager.h"
#import "VObjectManager.h"
#import "VAsyncTestHelper.h"

@interface VMockObjectManager : VObjectManager

@property (nonatomic, assign) BOOL mainUserLoggedIn;
@property (nonatomic, assign) BOOL mainUserProfileComplete;

@end

@implementation VMockObjectManager

@end


@interface VMockViewController : UIViewController <VAuthorizationProvider>

@property (nonatomic, assign) BOOL didPresentViewController;

@end

@implementation VMockViewController

@synthesize authorizedAction;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    self.didPresentViewController = YES;
}

@end

@interface VAuthorizedActionTests : XCTestCase

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (strong, nonatomic) VMockObjectManager *objectManager;
@property (strong, nonatomic) VMockViewController *viewController;
@property (strong, nonatomic) VAuthorizedAction *authroizedAction;
@property (strong, nonatomic) VAsyncTestHelper *asyncHelper;

@end

@implementation VAuthorizedActionTests

- (void)setUp
{
    [super setUp];
    
    self.dependencyManager = [[VDependencyManager alloc] init];
    self.objectManager = [[VMockObjectManager alloc] init];
    self.viewController = [[VMockViewController alloc] init];
    self.authroizedAction = [[VAuthorizedAction alloc] initWithObjectManager:self.objectManager
                                                           dependencyManager:self.dependencyManager];
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInvalidInputs
{
    XCTAssertThrows( [[VAuthorizedAction alloc] initWithObjectManager:nil dependencyManager:self.dependencyManager] );
    XCTAssertThrows( [[VAuthorizedAction alloc] initWithObjectManager:self.objectManager dependencyManager:nil] );
    XCTAssertThrows( [[VAuthorizedAction alloc] initWithObjectManager:nil dependencyManager:nil] );
    
    VAuthorizedAction *authroizedAction = [[VAuthorizedAction alloc] initWithObjectManager:self.objectManager
                                                                         dependencyManager:self.dependencyManager];
    
    XCTAssertThrows( [authroizedAction performFromViewController:self.viewController context:VAuthorizationContextDefault completion:nil]);
    XCTAssertThrows( [authroizedAction performFromViewController:nil context:VAuthorizationContextDefault completion:^{}]);
    XCTAssertThrows( [authroizedAction performFromViewController:nil context:VAuthorizationContextDefault completion:nil]);
}

- (void)testPerformAction1
{
    self.objectManager.mainUserLoggedIn = YES;
    self.objectManager.mainUserProfileComplete = YES;
    __block BOOL didPerformAction = NO;
    BOOL result = [self.authroizedAction performFromViewController:self.viewController
                                                       context:VAuthorizationContextDefault
                                                       completion:^
                   {
                       didPerformAction = YES;
                   }];
    XCTAssert( result );
    XCTAssert( didPerformAction );
}

- (void)testPerformAction2
{
    self.objectManager.mainUserLoggedIn = YES;
    self.objectManager.mainUserProfileComplete = NO;
    __block BOOL didPerformAction = NO;
    BOOL result = [self.authroizedAction performFromViewController:self.viewController
                                                       context:VAuthorizationContextDefault
                                                       completion:^
                   {
                       didPerformAction = YES;
                   }];
    XCTAssertFalse( result );
    XCTAssertFalse( didPerformAction );
}

- (void)testPerformAction3
{
    self.objectManager.mainUserLoggedIn = NO;
    self.objectManager.mainUserProfileComplete = NO;
    __block BOOL didPerformAction = NO;
    BOOL result = [self.authroizedAction performFromViewController:self.viewController
                                                       context:VAuthorizationContextDefault
                                                       completion:^
                   {
                       didPerformAction = YES;
                   }];
    XCTAssertFalse( result );
    XCTAssertFalse( didPerformAction );
}

@end
