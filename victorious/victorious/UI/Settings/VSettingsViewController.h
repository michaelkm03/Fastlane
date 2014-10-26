//
//  VSettingsViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSettingsViewController : UITableViewController

+ (UIViewController *)settingsContainer;//This contains a slight hack to get the header working, since the nav header doesn't play nicely with tableVCs

@end
