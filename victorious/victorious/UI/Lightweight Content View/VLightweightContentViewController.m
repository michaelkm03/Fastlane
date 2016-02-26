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
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VTabScaffoldViewController.h"
#import "VTrackingConstants.h"
#import "VTracking.h"
#import "UIView+AutoLayout.h"
#import "victorious-Swift.h"

static NSString * const kSequenceURLKey = @"sequenceURL";

@interface VLightweightContentViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *backgroundBlurredView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) BOOL hasVideoPlayed;
@property (nonatomic, strong) NSDate *videoLoadedDate;
@property (nonatomic, strong) VSequence *sequence;

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
    
    self.getStartedButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStyleSecondary;
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    // Hide container view before it's properly sized
    self.containerView.hidden = YES;
    
    [self setupVideoUI];
    
    self.getStartedButton.accessibilityIdentifier = VAutomationIdentifierWelcomeDismiss;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityIndicator startAnimating];
    
    if ( self.mediaUrl == nil )
    {
        NSString *sequenceId = [[self.dependencyManager stringForKey:kSequenceURLKey] lastPathComponent];
        SequenceFetchOperation *operation = [[SequenceFetchOperation alloc] initWithSequenceID:sequenceId streamID:nil];
        [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error)
         {
             if ( error != nil )
             {
                 [self didFailToLoadSequence];
                 return;
             }
             
             VSequence *sequence = (VSequence *)operation.result;
             VNode *node = (VNode *)[sequence firstNode];
             VAsset *asset = [node httpLiveStreamingAsset];
             if ( asset.dataURL == nil )
             {
                 [self didFailToLoadSequence];
                 return;
             }
             
             self.sequence = sequence;
             self.mediaUrl = asset.dataURL;
             VTracking *trackingData = sequence.streamItemPointerForStandloneStreamItem.tracking;
             [self.videoPlayerViewController enableTrackingWithTrackingItem:trackingData streamID:nil];
             [self showVideo];
         }];
        
        // Check orientation and update button state
        [self updateGetStartedButtonForCurrentOrientation];
    }
}

- (void)didFailToLoadSequence
{
    if ( [self.delegate respondsToSelector:@selector(failedToLoadSequenceInLightweightContentView:)] )
    {
        [self.delegate failedToLoadSequenceInLightweightContentView:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check orientation on first appearance and update constraints
    [self updateConstraintsForCurrentOrientation];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self updateConstraintsForCurrentOrientation];
         [self updateGetStartedButtonForCurrentOrientation];
     }
                                 completion:nil];
}

- (void)updateConstraintsForCurrentOrientation
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

- (void)updateGetStartedButtonForCurrentOrientation
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    self.getStartedButton.alpha = UIInterfaceOrientationIsPortrait(currentOrientation);
}

#pragma mark - Setup Video Playback View

- (void)setupVideoUI
{
    // Setup Video player
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    self.videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;

    [self.containerView addSubview:self.videoPlayerViewController.view];
    [self.containerView v_addFitToParentConstraintsToSubview:self.videoPlayerViewController.view];
}

#pragma mark - Select media sequence

- (void)trackSequenceViewStart
{
    if ( !self.hasVideoPlayed )
    {
        self.hasVideoPlayed = YES;
        
        VTracking *tracking = self.sequence.streamItemPointerForStandloneStreamItem.tracking;
        NSAssert( tracking != nil, @"Cannot track 'cellView' event because tracking data is missing." );
        
        NSUInteger videoLoadTime = [[NSDate date] timeIntervalSinceDate:self.videoLoadedDate] * 1000;
        NSDictionary *params = @{ VTrackingKeyTimeStamp : [NSDate date],
                                  VTrackingKeySequenceId : self.sequence.remoteId,
                                  VTrackingKeyUrls :tracking.viewStart ?: @[],
                                  VTrackingKeyLoadTime : @(videoLoadTime)
                                  };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
    }
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [self trackSequenceViewStart];
    
    // Adjust height of container view to match aspect ratio of video
    CGSize naturalSize = videoPlayer.naturalSize;
    
    CGFloat newHeight;
    
    if (naturalSize.width <= 0 || naturalSize.height <= 0)
    {
        newHeight = CGRectGetWidth(self.containerView.frame);
    }
    else
    {
        CGFloat aspectRatio = naturalSize.width / naturalSize.height;
        newHeight = CGRectGetWidth(self.containerView.frame) / aspectRatio;
    }
    
    self.containerHeightConstraint.constant = newHeight;
    
    [self.containerView layoutIfNeeded];
    
    // Reveal container view
    self.containerView.hidden = NO;
}

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

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    if ( [self.delegate respondsToSelector:@selector(videoHasCompletedInLightweightContentView:)] )
    {
        [self.delegate videoHasCompletedInLightweightContentView:self];
    }
}

#pragma mark - Video Playback

- (void)showVideo
{
    [self.videoPlayerViewController setItemURL:self.mediaUrl loop:NO];
    [self.videoPlayerViewController.player play];
    self.videoLoadedDate = [NSDate date];
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
    
    if ([self.delegate respondsToSelector:@selector(userWantsToDismissLightweightContentView:)])
    {
        [self.delegate userWantsToDismissLightweightContentView:self];
    }
}

@end
