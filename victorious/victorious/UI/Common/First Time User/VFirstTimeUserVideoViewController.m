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
#import "VSequence.h"
#import "UIImage+ImageEffects.h"

static NSString * const VPlayFirstTimeUserVideo = @"com.getvictorious.settings.playWelcomeVideo";

@interface VFirstTimeUserVideoViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
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
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Video Playback

- (void)showFirstTimeVideo
{
    
}

#pragma mark - Setters

- (void)setImageSnapshot:(UIImage *)imageSnapshot
{
    _imageSnapshot = imageSnapshot;
}

#pragma mark - Close Button Action

- (IBAction)getStartedButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save to NSUserDefaults

- (void)savePlaybackDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VPlayFirstTimeUserVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
