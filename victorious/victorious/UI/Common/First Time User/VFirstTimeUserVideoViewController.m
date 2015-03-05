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
#import "VContentViewRotationHelper.h"
#import "VTemplateGenerator.h"
#import "VActivityIndicatorView.h"
#import "VObjectManager+Sequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"

static NSString * const VPlayFirstTimeUserVideo = @"com.getvictorious.settings.playWelcomeVideo";

NSString * const kFTUSequenceURLPath = @"sequenceUrlPath";

@interface VFirstTimeUserVideoViewController () <VCVideoPlayerDelegate>

@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *videoPlayerView;

@property (nonatomic, strong) NSLayoutConstraint *videoPortraitCenterConstraint;

@property (nonatomic, strong) NSLayoutConstraint *videoTopPortraitLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoBottomPortraitLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoLeftPortraitLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoRightPortraitLayoutConstraint;

@property (nonatomic, strong) NSLayoutConstraint *videoTopLandscapeLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoBottomLandscapeLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoLeftLandscapeLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoRightLandscapeLayoutConstraint;

@property (nonatomic, assign) CGRect portraitFrame;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VContentViewRotationHelper *rotationHelper;

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

    // NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

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

    self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Portrait Constraints
    self.videoPortraitCenterConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:0.0f
                                                                       constant:0.0f];
    
    self.videoTopPortraitLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:0.0f
                                                                          constant:0.0f];
    
    self.videoBottomPortraitLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:0.5f
                                                                             constant:0.0f];

    self.videoLeftPortraitLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:0.5f
                                                                           constant:0.0f];
    
    self.videoRightPortraitLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0f
                                                                            constant:0.0f];

    // Landscape Constraints
    self.videoTopLandscapeLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
    
    self.videoBottomLandscapeLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0f
                                                                             constant:0.0f];
    
    self.videoLeftLandscapeLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0f
                                                                           constant:0.0f];
    
    self.videoRightLandscapeLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.videoPlayerViewController.view
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0f
                                                                            constant:0.0f];

    [self.view addSubview:self.videoPlayerViewController.view];
    NSArray *constraintsArray = @[ self.videoPortraitCenterConstraint, self.videoTopPortraitLayoutConstraint, self.videoBottomPortraitLayoutConstraint, self.videoLeftPortraitLayoutConstraint, self.videoRightPortraitLayoutConstraint, self.videoTopLandscapeLayoutConstraint, self.videoBottomLandscapeLayoutConstraint, self.videoLeftLandscapeLayoutConstraint, self.videoRightLandscapeLayoutConstraint ];
    [self.view addConstraints:constraintsArray];
    
    // Add Video player to view heirarchy
    self.videoPlayerViewController.view.hidden = NO;
    
    [self handleOrientationChange];
}

- (void)handleOrientationChange
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( UIInterfaceOrientationIsPortrait(currentOrientation) )
    {
        self.videoPortraitCenterConstraint.active = YES;
        self.videoTopPortraitLayoutConstraint.active = YES;
        self.videoBottomPortraitLayoutConstraint.active = YES;
        self.videoLeftPortraitLayoutConstraint.active = YES;
        self.videoRightPortraitLayoutConstraint.active = YES;
        
        self.videoTopLandscapeLayoutConstraint.active = NO;
        self.videoBottomLandscapeLayoutConstraint.active = NO;
        self.videoLeftLandscapeLayoutConstraint.active = NO;
        self.videoRightLandscapeLayoutConstraint.active = NO;
    }
    else if ( UIInterfaceOrientationIsLandscape(currentOrientation) )
    {
        self.videoPortraitCenterConstraint.active = NO;
        self.videoTopPortraitLayoutConstraint.active = NO;
        self.videoBottomPortraitLayoutConstraint.active = NO;
        self.videoLeftPortraitLayoutConstraint.active = NO;
        self.videoRightPortraitLayoutConstraint.active = NO;
        
        self.videoTopLandscapeLayoutConstraint.active = YES;
        self.videoBottomLandscapeLayoutConstraint.active = YES;
        self.videoLeftLandscapeLayoutConstraint.active = YES;
        self.videoRightLandscapeLayoutConstraint.active = YES;
    }
    
    [self.view setNeedsUpdateConstraints];
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
