//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRootViewController.h"
#import "VMenuController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VConstants.h"

@interface  VRootViewController ()
@end

@implementation VRootViewController

- (void)awakeFromNib
{
    if (IS_IPHONE_5)
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKeyPath:kVMenuBackgroundImage5] applyLightEffect];
    else
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKeyPath:kVMenuBackgroundImage] applyLightEffect];

    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuController class])];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
}

@end
