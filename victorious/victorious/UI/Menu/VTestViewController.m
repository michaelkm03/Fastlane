//
//  VTestViewController.m
//  victorious
//
//  Created by goWorld on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTestViewController.h"
#import "UIViewController+VSideMenuViewController.h"


@implementation VTestViewController

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

@end
