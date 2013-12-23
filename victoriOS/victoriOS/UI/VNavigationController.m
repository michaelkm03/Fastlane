//
//  VNavigationController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VNavigationController.h"
#import "REFrostedViewController.h"

@implementation VNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}

@end
