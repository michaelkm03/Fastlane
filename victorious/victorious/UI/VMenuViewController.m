//
//  VMenuViewController.m
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VMenuViewController.h"
#import "VMenuTableViewController.h"

@interface VMenuViewController()
@end

@implementation VMenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    VMenuTableViewController *menuTableViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuTableViewController class])];
    [self addChildViewController:menuTableViewController];
    [self.containerView addSubview:menuTableViewController.view];
    [menuTableViewController didMoveToParentViewController:self];
}

- (IBAction)tapGestureAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
