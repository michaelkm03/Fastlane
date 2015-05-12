//
//  VComposeMessageNavigationDestination.m
//  victorious
//
//  Created by Patrick Lynch on 5/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VComposeMessageNavigationDestination.h"
#import "VMessageContainerViewController.h"
#import "VInboxViewController.h"
#import "VUserProfileViewController.h"
#import "VUserSearchViewController.h"
#import "VObjectManager+Users.h"

@interface VComposeMessageNavigationDestination()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VComposeMessageNavigationDestination

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VComposeMessageNavigationDestination *destination = [[VComposeMessageNavigationDestination alloc] init];
    destination.dependencyManager = dependencyManager;
    return destination;
}

- (BOOL)shouldNavigateFromViewController:(UIViewController *)viewController
                withAlternateDestination:(__autoreleasing id *)alternateViewController
{
    if ( [viewController isKindOfClass:[VInboxViewController class]] )
    {
        VUserSearchViewController *userSearch = [VUserSearchViewController newWithDependencyManager:self.dependencyManager];
        userSearch.searchContext = VObjectManagerSearchContextMessage;
        *alternateViewController = userSearch;
    }
    else if ( [viewController isKindOfClass:[VUserProfileViewController class]] )
    {
        VUser *currentUser = ((VUserProfileViewController *)viewController).user;
        *alternateViewController = [VMessageContainerViewController messageViewControllerForUser:currentUser
                                                                               dependencyManager:self.dependencyManager];
    }
    
    return NO;
}

@end
