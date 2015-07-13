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

static NSString * const kPromptKey = @"prompt";
static NSString * const kHashtagKey = @"hashtagText";
static NSString * const kPlaceholderTextKey = @"placeholderText";
static NSString * const kShowsSkipButtonKey = @"showsSkipButton";
static NSString * const kSkipButtonTextKey = @"skipButtonText";
static NSString * const kDoneButtonTextKey = @"doneButtonText";

@interface VForcedWorkspaceContainerViewController ()

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
    
    self.titleLabel.text = [self.dependencyManager stringForKey:kPromptKey];
    self.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.doneButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.titleLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
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
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helpers

- (void)configureWorkspace
{
    // Replace default text in workspace dependency manager with one from ours
    VTextWorkspaceFlowController *textFlow = [VTextWorkspaceFlowController textWorkspaceFlowControllerWithDependencyManager:self.dependencyManager addedDependencies:@{kDefaultTextKey : [self.dependencyManager stringForKey:kPlaceholderTextKey]}];
    
    [self addChildViewController:textFlow.flowRootViewController];
    [self.containerView addSubview:textFlow.flowRootViewController.view];
    textFlow.flowRootViewController.view.frame = self.containerView.frame;
    [textFlow.flowRootViewController didMoveToParentViewController:self];
}

- (BOOL)showsSkipButton
{
    return [[self.dependencyManager numberForKey:kShowsSkipButtonKey] boolValue];
}

- (void)updateDoneButton
{
    
}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self.delegate continueRegistrationFlow];
}

#pragma mark - VLoginFlowScreen

@synthesize delegate = _delegate;

@end
