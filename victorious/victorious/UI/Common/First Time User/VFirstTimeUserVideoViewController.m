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
#import "UIImage+ImageEffects.h"

static NSString * const VPlayFirstTimeUserVideo = @"com.getvictorious.settings.playWelcomeVideo";

@interface VFirstTimeUserVideoViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet VButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

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
    self.getStartedButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStylePrimary;
    
    // Set the blurred background image
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Once shown, don't show again
    [self savePlaybackDefaults];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Setters

- (void)setImageSnapshot:(UIImage *)imageSnapshot
{
    _imageSnapshot = imageSnapshot;
    
    UIImage *image = [_imageSnapshot applyDarkEffect];
    self.backgroundImageView.image = image;
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
