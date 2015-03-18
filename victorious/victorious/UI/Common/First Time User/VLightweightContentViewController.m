//
//  VLightweightContentViewController.m
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLightweightContentViewController.h"
#import "VButton.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "VCVideoPlayerViewController.h"
#import "VTemplateGenerator.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Sequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VFirstTimeInstallHelper.h"
#import "VScaffoldViewController.h"
#import "VTrackingConstants.h"

@interface VLightweightContentViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *backgroundBlurredView;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VLightweightContentViewController

#pragma mark - Initializers

+ (VLightweightContentViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"firstTimeUserVideo"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VLightweightContentViewController *firstTimeVC = [self instantiateFromStoryboard:@"FirstTimeVideo"];
    firstTimeVC.dependencyManager = dependencyManager;
    return firstTimeVC;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *vcDictionary = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerLightweightContentViewComponentKey];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:vcDictionary];
    self.dependencyManager = childDependencyManager;

    // Set the Get Started button style
    self.getStartedButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStyleSecondary;
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    [self setupVideoUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.delegate videoHasStarted:self];
    
    // Play the video
    [self showVideo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Orientation Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
         
         [self.portraitConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
          {
              constraint.active = UIInterfaceOrientationIsPortrait(currentOrientation);
          }];
         [self.landscapeConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
          {
              constraint.active = UIInterfaceOrientationIsLandscape(currentOrientation);
          }];
         
         [self.view layoutIfNeeded];
     }
                                 completion:nil];
}

#pragma mark - Setup Video Playback View

- (void)setupVideoUI
{
    [self.activityIndicator startAnimating];
    
    // Setup Video player
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    self.videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;
    
    self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;;
    
    [self.containerView addSubview:self.videoPlayerViewController.view];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[videoPlayerView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"videoPlayerView":self.videoPlayerViewController.view}]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{@"videoPlayerView":self.videoPlayerViewController.view}]];
    
    self.videoPlayerViewController.view.hidden = NO;
}

#pragma mark - Dependency Manager Setter

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if (_dependencyManager != nil)
    {
        [self fetchMediaSequenceObject];
    }
}

#pragma mark - Select media sequence

- (void)fetchMediaSequenceObject
{
    NSString *sequenceId = [[self.dependencyManager stringForKey:kFTUSequenceURLPath] lastPathComponent];
    if (sequenceId != nil)
    {
        [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                             successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             VSequence *sequence = (VSequence *)resultObjects.firstObject;
             VNode *node = (VNode *)[sequence firstNode];
             VAsset *asset = [node mp4Asset];
             if (asset.dataURL != nil)
             {
                 self.mediaUrl = asset.dataURL;
             }
             else
             {
                 self.mediaUrl = nil;
             }
             
         }
                                                failBlock:^(NSOperation *operation, NSError *error)
         {
             self.mediaUrl = nil;
         }];
    }
    else
    {
        self.mediaUrl = nil;
    }
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self.activityIndicator stopAnimating];
}

- (void)videoPlayerFailed:(VCVideoPlayerViewController *)videoPlayer
{
    [self.activityIndicator stopAnimating];
    [self getStartedButtonAction:nil];
}

#pragma mark - Video Playback

- (void)showVideo
{
    [self.videoPlayerViewController setItemURL:self.mediaUrl loop:NO];
    [self.videoPlayerViewController.player play];
}

#pragma mark - Close Button Action

- (IBAction)getStartedButtonAction:(id)sender
{
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
        self.videoPlayerViewController.view.hidden = YES;
        self.videoPlayerViewController = nil;
    }

    [self.delegate videoHasCompleted:self];
}

@end
