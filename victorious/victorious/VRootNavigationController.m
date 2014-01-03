//
//  VRootNavigationController.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VRootNavigationController.h"
#import "VSettingsViewController.h"

@interface VRootNavigationController ()

@end

@implementation VRootNavigationController

- (void)showViewControllerForSelectedMenuRow:(VMenuTableViewControllerRow)row{
    switch(row){
        case VMenuTableViewControllerRowHome:{
            // TODO: show home
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowOwnerChannel:{
            // TODO: show owner channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowCommunityChannel:{
            // TODO: show community channel
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowForums:{
            // TODO: show forums
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowInbox:{
            // TODO: show inbox
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowProfile:{
            // TODO: show profile
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowSettings:{
            self.viewControllers = @[[VSettingsViewController sharedSettingsViewController]];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }case VMenuTableViewControllerRowHelp:{
            // TODO: show help
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
}

@end
