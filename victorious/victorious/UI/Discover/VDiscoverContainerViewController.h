//
//  VDiscoverContainerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"

#import <UIKit/UIKit.h>

@interface VDiscoverContainerViewController : UIViewController <VHasManagedDependencies, VNavigationDestination, UINavigationControllerDelegate>

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

@property (nonatomic, weak) IBOutlet UIView *searchBarContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
