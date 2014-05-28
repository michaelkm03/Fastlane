//
//  VSegmentedViewControllerSegue.m
//  victorious
//
//  Created by Gary Philipp on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSegmentedViewControllerSegue.h"

@implementation VSegmentedViewControllerSegue

- (void)perform
{
    self.segmentedTabViewController = self.sourceViewController;
    UIViewController*   destinationViewController = self.destinationViewController;
    
    destinationViewController.navigationController.navigationBarHidden = YES;
    
    [self.segmentedTabViewController addChildViewController:destinationViewController];
    [self.segmentedTabViewController.containerView addSubview:destinationViewController.view];
    
    [destinationViewController didMoveToParentViewController:self.segmentedTabViewController];
}

@end
