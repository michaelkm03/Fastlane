//
//  VPurchaseSettingsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

@interface VPurchaseSettingsViewController : UITableViewController <VHasManagedDependancies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
