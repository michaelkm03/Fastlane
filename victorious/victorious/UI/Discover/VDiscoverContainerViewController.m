//
//  VDiscoverContainerViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverContainerViewController.h"

@interface VDiscoverContainerViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createButton;

@end

@implementation VDiscoverContainerViewController

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"discover"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.headerLabel.text = NSLocalizedString(@"Discover", nil);
}

@end
