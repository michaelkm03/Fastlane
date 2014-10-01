//
//  VAuthorizationViewControllerFactorTests.m
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VSwizzle.h"
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"
#import "VProfileCreateViewController.h"
#import "VAuthorizationViewControllerFactory.h"

@interface ObjectManagerNotLoggedIn : NSObject

@end

@implementation ObjectManagerNotLoggedIn
- (BOOL) mainUserProfileComplete { return NO; }
- (BOOL) mainUserLoggedIn { return NO; }
@end

@interface ObjectManagerIncomplete : NSObject

@end

@implementation ObjectManagerIncomplete
- (BOOL) mainUserProfileComplete { return NO; }
- (BOOL) mainUserLoggedIn { return YES; }
@end


@interface ObjectManagerInvalidState : NSObject

@end

@implementation ObjectManagerInvalidState
- (BOOL) mainUserProfileComplete { return YES; }
- (BOOL) mainUserLoggedIn { return NO; }
@end


@interface ObjectManagerComplete : NSObject

@end

@implementation ObjectManagerComplete
- (BOOL) mainUserProfileComplete { return YES; }
- (BOOL) mainUserLoggedIn { return YES; }
@end


@interface VAuthorizationViewControllerFactorTests : XCTestCase

@end

@implementation VAuthorizationViewControllerFactorTests

- (void)setUp
{
    
}

- (void)testWithObjectManagerUserProfileIncomplete
{
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserProfileComplete)
                         swizzledClass:[ObjectManagerIncomplete class]
                      swizzledSelector:@selector(mainUserProfileComplete)];
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserLoggedIn)
                         swizzledClass:[ObjectManagerIncomplete class]
                      swizzledSelector:@selector(mainUserLoggedIn)];
    
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNotNil( output );
    XCTAssert( [output isMemberOfClass:[VProfileCreateViewController class]] );
}

- (void)testWithObjectManagerUserProfileComplete
{
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserProfileComplete)
                         swizzledClass:[ObjectManagerComplete class]
                      swizzledSelector:@selector(mainUserProfileComplete)];
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserLoggedIn)
                         swizzledClass:[ObjectManagerComplete class]
                      swizzledSelector:@selector(mainUserLoggedIn)];
    
    // Calling code should check the 'authorized' property before getting a view controller from this method,
    // threfore theoutput is nil because there is not view controller to display for that state
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNil( output );
}

- (void)testWithObjectManagerUserProfileLoggedIn
{
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserProfileComplete)
                         swizzledClass:[ObjectManagerNotLoggedIn class]
                      swizzledSelector:@selector(mainUserProfileComplete)];
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserLoggedIn)
                         swizzledClass:[ObjectManagerNotLoggedIn class]
                      swizzledSelector:@selector(mainUserLoggedIn)];
    
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
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserProfileComplete)
                         swizzledClass:[ObjectManagerInvalidState class]
                      swizzledSelector:@selector(mainUserProfileComplete)];
    [VSwizzle swizzleWithOriginalClass:[VObjectManager class]
                      originalSelector:@selector(mainUserLoggedIn)
                         swizzledClass:[ObjectManagerInvalidState class]
                      swizzledSelector:@selector(mainUserLoggedIn)];
    
    // This state should never occur, and therefore the method will reutrn nil
    id output = [VAuthorizationViewControllerFactory requiredViewController];
    XCTAssertNil( output );
}

@end
