//
//  VFirstTimeUserVideoViewController.m
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFirstTimeUserVideoViewController.h"
#import "VButton.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "UIImage+ImageEffects.h"
#import "VCVideoPlayerViewController.h"
#import "VTemplateGenerator.h"
#import "VActivityIndicatorView.h"
#import "VObjectManager+Sequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"

static NSString * const VPlayFirstTimeUserVideo = @"com.getvictorious.settings.playWelcomeVideo";

NSString * const kFTUSequenceURLPath = @"sequenceUrlPath";

@interface VFirstTimeUserVideoViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, assign) CGRect portraitFrame;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;

@property (nonatomic, strong) NSURL *mediaUrl;

@end

@implementation VFirstTimeUserVideoViewController

#pragma mark - Initializers

+ (VFirstTimeUserVideoViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"firstTimeUserVideo"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VFirstTimeUserVideoViewController *firstTimeVC = [self instantiateFromStoryboard:@"FirstTimeVideo"];
    firstTimeVC.dependencyManager = dependencyManager;
    return firstTimeVC;
}

- (BOOL)hasBeenShown
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:VPlayFirstTimeUserVideo] boolValue];
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the Get Started button style
    self.getStartedButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStyleSecondary;
    
    // Setup player
    [self setupVideoUI];

    // Setup Media Playback
    [self fetchMediaSequenceObject];
}

- (void)setupVideoUI
{
    // Show activity indicator
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

- (void)fetchMediaSequenceObject
{
    NSString *sequenceId = [[self.dependencyManager stringForKey:kFTUSequenceURLPath] lastPathComponent];
    [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                         successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        self.sequence = (VSequence *)resultObjects.firstObject;
        VNode *node = (VNode *)[self.sequence firstNode];
        VAsset *asset = [node mp4Asset];
        [self setupMediaPlayback:asset];
    }
                                            failBlock:^(NSOperation *operation, NSError *error)
    {
        [self closeVideoWindow];
    }];
}

- (void)setupMediaPlayback:(VAsset *)asset
{
    if (asset.dataURL != nil)
    {
        self.mediaUrl = asset.dataURL;
    }
    else
    {
        [self closeVideoWindow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Once shown, don't show again
    [self savePlaybackDefaults];
    
    // Play the video
    [self showFirstTimeVideo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.backgroundImageView.image = [self.imageSnapshot applyDarkEffect];
    //[self updateOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
    }
    self.videoPlayerViewController.view.hidden = YES;
    self.videoPlayerViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self.activityIndicator stopAnimating];
}

#pragma mark - Video Playback

- (void)showFirstTimeVideo
{
    [self.videoPlayerViewController setItemURL:self.mediaUrl loop:NO];
    [self.videoPlayerViewController.player play];
}

#pragma mark - Setters

- (void)setImageSnapshot:(UIImage *)imageSnapshot
{
    _imageSnapshot = imageSnapshot;
}

#pragma mark - Close Button Action

- (IBAction)getStartedButtonAction:(id)sender
{
    [self closeVideoWindow];
}

#warning REMOVE ME
- (void)closeVideoWindow
{
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
        self.videoPlayerViewController.view.hidden = YES;
        self.videoPlayerViewController = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save to NSUserDefaults

- (void)savePlaybackDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VPlayFirstTimeUserVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
