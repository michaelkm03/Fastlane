//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRootViewController.h"
#import "VMenuController.h"
#import "UIImage+ImageEffects.h"

@interface  VRootViewController ()
@end

@implementation VRootViewController

- (void)awakeFromNib
{
    self.backgroundImage = [[UIImage imageNamed:@"avatar.jpg"] applyLightEffect];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuController class])];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
}

@end
