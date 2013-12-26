//
//  VMenuViewController.m
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
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

    CAShapeLayer *shapeMaskLayer = [CAShapeLayer layer];
    shapeMaskLayer.path = [[UIBezierPath bezierPathWithRect:self.containerView.bounds] CGPath];
    shapeMaskLayer.frame = self.containerView.frame;
    self.imageView.layer.mask = shapeMaskLayer;
}

- (IBAction)tapGestureAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
