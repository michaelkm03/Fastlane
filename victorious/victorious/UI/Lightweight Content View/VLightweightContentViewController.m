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
#import "VScaffoldViewController.h"
#import "VTrackingConstants.h"

static NSString * const kSequenceURLKey = @"sequenceURL";

@interface VLightweightContentViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *backgroundBlurredView;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Url referencing video to be played
 */
@property (nonatomic, strong) NSURL *mediaUrl;

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
    VLightweightContentViewController *firstTimeVC = [self instantiateFromStoryboard:@"LightweightContentView"];
    firstTimeVC.dependencyManager = dependencyManager;
    return firstTimeVC;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *vcDictionary = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerFirstTimeContentKey];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:vcDictionary];
    self.dependencyManager = childDependencyManager;

    self.getStartedButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStyleSecondary;
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    [self setupVideoUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityIndicator startAnimating];
    
    if ( self.mediaUrl == nil )
    {
        [self fetchMediaSequenceObject];
    }
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

#pragma mark - Select media sequence

- (void)fetchMediaSequenceObject
{
    NSString *sequenceId = [[self.dependencyManager stringForKey:kSequenceURLKey] lastPathComponent];
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
                 [self showVideo];
             }
             else
             {
                 if ( [self.delegate respondsToSelector:@selector(failedToLoadSequenceInLightweightContentView:)] )
                 {
                     [self.delegate failedToLoadSequenceInLightweightContentView:self];
                 }
             }
         }
                                                failBlock:^(NSOperation *operation, NSError *error)
         {
             if ( [self.delegate respondsToSelector:@selector(failedToLoadSequenceInLightweightContentView:)] )
             {
                 [self.delegate failedToLoadSequenceInLightweightContentView:self];
             }
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
    if ( [self.delegate respondsToSelector:@selector(videoHasStartedInLightweightContentView:)] )
    {
        [self.delegate videoHasStartedInLightweightContentView:self];
    }
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
    
    if ( [self.delegate respondsToSelector:@selector(videoHasCompletedInLightweightContentView:)] )
    {
        [self.delegate videoHasCompletedInLightweightContentView:self];
    }
}

@end
