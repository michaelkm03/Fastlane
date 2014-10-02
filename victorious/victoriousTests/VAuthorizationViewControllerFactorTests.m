//
//  VAuthorizationViewControllerFactorTests.m
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSObject+VMethodSwizzling.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VProfileCreateViewController.h"
#import "VAuthorizationViewControllerFactory.h"

@interface VAuthorizationViewControllerFactorTests : XCTestCase

@end

@implementation VAuthorizationViewControllerFactorTests

- (void)testWithObjectManagerUserProfileIncomplete
{
    [VObjectManager v_swizzleMethod:@selector(mainUserProfileComplete) withBlock:^BOOL{
        return NO;
    }];
    [VObjectManager v_swizzleMethod:@selector(mainUserLoggedIn) withBlock:^BOOL{
        return YES;
    }];
    
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNotNil( output );
    XCTAssert( [output isMemberOfClass:[VProfileCreateViewController class]] );
}

- (void)testWithObjectManagerUserProfileComplete
{
    [VObjectManager v_swizzleMethod:@selector(mainUserProfileComplete) withBlock:^BOOL{
        return YES;
    }];
    [VObjectManager v_swizzleMethod:@selector(mainUserLoggedIn) withBlock:^BOOL{
        return YES;
    }];
    
    // Calling code should check the 'authorized' property before getting a view controller from this method,
    // threfore theoutput is nil because there is not view controller to display for that state
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNil( output );
}

- (void)testWithObjectManagerUserProfileLoggedIn
{
    [VObjectManager v_swizzleMethod:@selector(mainUserProfileComplete) withBlock:^BOOL{
        return NO;
    }];
    [VObjectManager v_swizzleMethod:@selector(mainUserLoggedIn) withBlock:^BOOL{
        return NO;
    }];
    
    // Expecting a UINavigationController with VLoginViewController as root view controller
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNotNil( output );
    XCTAssert( [output isMemberOfClass:[UINavigationController class]] );
    UINavigationController *navController = (UINavigationController *)output;
    XCTAssert( navController.viewControllers.count > 0 );
    XCTAssertNotNil( navController.viewControllers[0] );
    XCTAssert( [navController.viewControllers[0] isMemberOfClass:[VLoginViewController class]] );
}

- (void)testWithObjectManagerUserProfileInvalid
{
    [VObjectManager v_swizzleMethod:@selector(mainUserProfileComplete) withBlock:^BOOL{
        return YES;
    }];
    [VObjectManager v_swizzleMethod:@selector(mainUserLoggedIn) withBlock:^BOOL{
        return NO;
    }];
    
    // This state should never occur, and therefore the method will reutrn nil
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNil( output );
}

@end
