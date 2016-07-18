//
//  VSettingsViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VDependencyManager+VAccessoryScreens.h"

@interface VSettingsViewController : UITableViewController <VHasManagedDependencies, VNavigationDestination, VAccessoryNavigationSource>

// These are exposed here since they are used in the Swift extension
@property (weak, nonatomic) IBOutlet UILabel *versionString;

- (void)sendHelp;

@end
