//
//  VCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"

// Dependencies
#import "VDependencyManager.h"

// Strategy
#import "VCreationFlowStrategy.h"

NSString * const VCreationFlowControllerCreationTypeKey = @"creationType";

@interface VCreationFlowController () <VCreationFlowStrategyDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) VCreationFlowStrategy *strategy;

@end

@implementation VCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSNumber *numberForCreationTypeKey = [dependencyManager templateValueOfType:[NSNumber class] forKey:VCreationFlowControllerCreationTypeKey];
    if (numberForCreationTypeKey == nil)
    {
        NSAssert(false, @"We need a creation type for the creation flow!");
    }
    VCreationType creationType = [numberForCreationTypeKey integerValue];
    VCreationFlowStrategy *strategy = [VCreationFlowStrategy newCreationFlowStrategyWithDependencyManager:dependencyManager
                                                                                     creationType:creationType
                                                                         flowNavigationController:self];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIViewController *rootViewController = [strategy rootViewControllerForCreationFlow];
    rootViewController.navigationItem.leftBarButtonItem = cancelButton;

    self = [super initWithRootViewController:rootViewController];
    if (self != nil)
    {
        _strategy = strategy;
        _strategy.delegate = self;
        self.delegate = strategy;
    }
    return self;
}

#pragma mark - View Lifecycle

// Force Status bar hidden
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
    self.delegate = self.strategy;
}

#pragma mark - Notifying Delegate

- (void)cancel
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

#pragma mark - VCreationFlowStrategyDelegate

- (void)creationFlowStrategy:(VCreationFlowStrategy *)strategy
    finishedWithPreviewImage:(UIImage *)previewImage
            capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.creationFlowDelegate creationFLowController:self
                             finishedWithPreviewImage:previewImage
                                     capturedMediaURL:capturedMediaURL];
}

- (void)creationFlowStrategyDidCancel:(VCreationFlowStrategy *)strategy
{
    [self cancel];
}

@end
