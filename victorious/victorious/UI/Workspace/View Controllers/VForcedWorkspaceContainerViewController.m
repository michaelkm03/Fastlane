//
//  VForcedWorkspaceContainerViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VForcedWorkspaceContainerViewController.h"
#import "VTextWorkspaceFlowController.h"
#import "VEditableTextPostViewController.h"
#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager+VStatusBarStyle.h"

NSString * const kHashtagKey = @"hashtagText";

static NSString * const kPromptKey = @"prompt";
static NSString * const kPlaceholderTextKey = @"placeholderText";
static NSString * const kShowsSkipButtonKey = @"showsSkipButton";
static NSString * const kSkipButtonTextKey = @"skipButtonText";
static NSString * const kDoneButtonTextKey = @"doneButtonText";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";

@interface VForcedWorkspaceContainerViewController () <VTextWorkspaceFlowControllerDelegate>

@property (strong, nonatomic) VTextWorkspaceFlowController *flowController;
@property (assign, nonatomic) BOOL ableToPublish;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) VDependencyManager *dependencyManager;

@end

@implementation VForcedWorkspaceContainerViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *identifier = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:identifier bundle:bundle];
    
    self = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add text workspace as child view controller
    [self configureWorkspace];
    
    // Disable swipe back gesture
    self.navigationItem.hidesBackButton = YES;
    
    self.titleLabel.text = NSLocalizedString([self.dependencyManager stringForKey:kPromptKey], @"");
    self.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.doneButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerButton1FontKey];
    self.titleLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    [self updateDoneButton:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentedViewController == nil)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.presentedViewController == nil)
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.dependencyManager statusBarStyleForKey:kStatusBarStyleKey];
}

#pragma mark - Helpers

- (void)configureWorkspace
{
    // Replace default text in workspace dependency manager with one from ours and inject default hashtag
    NSDictionary *dependencies = @{kDefaultTextKey : [self.dependencyManager stringForKey:kPlaceholderTextKey],
                                   kHashtagKey : [self.dependencyManager stringForKey:kHashtagKey]};
    self.flowController = [VTextWorkspaceFlowController textWorkspaceFlowControllerWithDependencyManager:self.dependencyManager
                                                                                       addedDependencies:dependencies];
    self.flowController.delegate = self;
    
    __weak typeof(self) welf = self;
    self.flowController.publishCompletionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        [welf.delegate continueRegistrationFlow];
    };
    
    // Add workspace as child view controller
    [self addChildViewController:self.flowController.flowRootViewController];
    [self.containerView addSubview:self.flowController.flowRootViewController.view];
    [self.containerView v_addFitToParentConstraintsToSubview:self.flowController.flowRootViewController.view];
    [self.flowController.flowRootViewController didMoveToParentViewController:self];
}

- (BOOL)showsSkipButton
{
    return [[self.dependencyManager numberForKey:kShowsSkipButtonKey] boolValue];
}

- (void)updateDoneButton:(BOOL)animated
{
    if ([self showsSkipButton] && !self.ableToPublish)
    {
        [self.doneButton setTitle:NSLocalizedString([self.dependencyManager stringForKey:kSkipButtonTextKey], @"")
                         forState:UIControlStateNormal];
    }
    else
    {
        [self.doneButton setTitle:NSLocalizedString([self.dependencyManager stringForKey:kDoneButtonTextKey], @"")
                         forState:UIControlStateNormal];
        
        self.doneButton.enabled = self.ableToPublish;
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^
         {
             self.doneButton.layer.opacity = self.ableToPublish ? 1.0f : 0.5f;
         }];
    }
}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self.flowController publishContent];
}

#pragma mark - Text Post Flow Controller

- (void)contentDidBecomePublishable:(BOOL)publishable
{
    self.ableToPublish = publishable;
    [self updateDoneButton:YES];
}

- (BOOL)isCreationForced
{
    return YES;
}

#pragma mark - VLoginFlowScreen

@synthesize delegate = _delegate;

@end
