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
#import "VSolidColorBackground.h"

// Subclasses
#import "VAbstractImageVideoCreationFlowController.h"

static NSString * const kCloseButtonIconKey = @"closeIcon";
static NSString * const kBarBackgroundKey = @"navBarBackground";
static NSString * const kBarTintColorKey = @"barTintColor";

@interface VCreationFlowController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VSolidColorBackground *background = [self.dependencyManager templateValueOfType:[VSolidColorBackground class]
                                                                             forKey:kBarBackgroundKey];
    self.navigationBar.barTintColor = background.backgroundColor;
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [self.dependencyManager colorForKey:kBarTintColorKey];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Public Methods

- (void)addCloseButtonToViewController:(UIViewController *)viewController
{
    UIImage *closeImage = [self.dependencyManager imageForKey:kCloseButtonIconKey];
    UIBarButtonItem *closeButton;
    
    if (closeImage != nil)
    {
        closeButton = [[UIBarButtonItem alloc] initWithImage:closeImage
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(selectedCancel:)];
    }
    else
    {
        closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(selectedCancel:)];
    }
    viewController.navigationItem.leftBarButtonItem = closeButton;
}

- (BOOL)shouldShowPublishText
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        return [self.creationFlowDelegate shouldShowPublishScreenForFlowController];
    }
    return YES;
}

- (void)selectedCancel:(UIBarButtonItem *)cancelButton
{
    self.delegate = nil;
    self.interactivePopGestureRecognizer.delegate = nil;
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
