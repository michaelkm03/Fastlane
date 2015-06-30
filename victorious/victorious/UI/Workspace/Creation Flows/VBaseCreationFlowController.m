//
//  VBaseCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

// Subclasses
#import "VImageCreationFlowController.h"

// Keys
NSString * const VCreationFLowCaptureScreenKey = @"captureScreen";

@interface VBaseCreationFlowController ()

@end

@implementation VBaseCreationFlowController

+ (instancetype)newCreationFlowControllerWithCreationType:(VCreationType)type
                                     andDependencyManager:(VDependencyManager *)dependencyManager
{
    VBaseCreationFlowController *creationFlowController;
    switch (type)
    {
        case VCreationTypeImage:
            creationFlowController = [[VImageCreationFlowController alloc] initWithDependencyManager:dependencyManager];
            break;
        case VCreationTypeGIF:
            break;
        case VCreationTypePoll:
            break;
        case VCreationTypeText:
            break;
        case VCreationTypeVideo:
            break;
        case VCreationTypeUnknown:
            return nil;
    }
    return creationFlowController;
}

#pragma mark - Init methods

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        UIViewController *captureViewController = [dependencyManager viewControllerForKey:VCreationFLowCaptureScreenKey];
        [self addCloseButtonToViewController:captureViewController];
        [self pushViewController:captureViewController animated:NO];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup from dependencymanager
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Target/Action

- (void)selectedCancel:(UIBarButtonItem *)cancelButton
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Navigation Item Configuration

- (void)addCloseButtonToViewController:(UIViewController *)viewController
{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(selectedCancel:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;
}

@end
