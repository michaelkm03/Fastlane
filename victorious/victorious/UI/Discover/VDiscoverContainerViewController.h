//
//  VDiscoverContainerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VDeeplinkHandler.h"
#import "VTabMenuContainedViewControllerNavigation.h"
#import <UIKit/UIKit.h>

@protocol SearchResultsViewControllerDelegate;

@interface VDiscoverContainerViewController : UIViewController <VHasManagedDependencies, VNavigationDestination, VTabMenuContainedViewControllerNavigation, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *searchBarContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
