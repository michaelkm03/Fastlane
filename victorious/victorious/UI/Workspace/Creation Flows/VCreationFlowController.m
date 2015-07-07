//
//  VCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

// Subclasses
#import "VImageCreationFlowController.h"

@interface VCreationFlowController ()

@end

@implementation VCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self init];
    if (self != nil)
    {
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#warning setup from dependencymanager
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Public Methods

- (void)addCloseButtonToViewController:(UIViewController *)viewController
{
#warning Templatize me
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(selectedCancel:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;
}

#pragma mark - Target/Action

- (void)selectedCancel:(UIBarButtonItem *)cancelButton
{
    self.delegate = nil;
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
