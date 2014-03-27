//
//  VSettingsViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import <UIKit/UIKit.h>

extern  NSString*   const   kAccountUpdateViewControllerDomain;

NS_ENUM(NSUInteger, VAccountUpdateViewControllerErrorCode)
{
    VAccountUpdateViewControllerBadUsernameErrorCode,
    VAccountUpdateViewControllerBadPasswordErrorCode,
    VAccountUpdateViewControllerBadEmailAddressErrorCode
};

@interface VSettingsViewController : UITableViewController

+ (VSettingsViewController *)settingsViewController;

@end
