//
//  VContentPollCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollCell.h"

// Subviews
#import "VResultView.h"

// Theme
#import "VThemeManager.h"

#import "VCVideoPlayerViewController.h"

static const CGFloat kDesiredPollCellHeight = 214.0f;

@interface VContentPollCell () <VCVideoPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *answerAContainer;
@property (weak, nonatomic) IBOutlet UIView *answerBContainer;

@property (nonatomic, weak) IBOutlet UIImageView *answerAThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerAButton;
@property (nonatomic, weak) IBOutlet UIImageView *answerBThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerBButton;
@property (nonatomic, weak) IBOutlet VResultView *answerAResultView;
@property (nonatomic, weak) IBOutlet VResultView *answerBResultView;
@property (nonatomic, weak) IBOutlet UIView *answerAVideoPlayerContainer;
@property (nonatomic, weak) IBOutlet UIView *answerBVideoPlayerContainer;

@property (nonatomic, strong) VCVideoPlayerViewController *aVideoPlayerViewController;
@property (nonatomic, strong) VCVideoPlayerViewController *bVideoPlayerViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerAContainerViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerBContainerViewWidth;

@property (nonatomic, assign) BOOL answerBIsVideo;
@property (nonatomic, assign) BOOL answerAIsVideo;

@end

@implementation VContentPollCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kDesiredPollCellHeight);
}

#pragma mark - NSOBject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.answerAResultView setProgress:0.0f animated:NO];
    [self.answerBResultView setProgress:0.0f animated:NO];
    
    [self.answerAResultView setColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor]];
    [self.answerBResultView setColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor]];
}

#pragma mark - Property Accessors

- (void)setAnswerAThumbnailMediaURL:(NSURL *)answerAThumbnailMediaURL
{
    _answerAThumbnailMediaURL = [answerAThumbnailMediaURL copy];
    [self.answerAThumbnail setImageWithURL:_answerAThumbnailMediaURL];
}

- (void)setAnswerBThumbnailMediaURL:(NSURL *)answerBThumbnailMediaURL
{
    _answerBThumbnailMediaURL = [answerBThumbnailMediaURL copy];
    [self.answerBThumbnail setImageWithURL:_answerBThumbnailMediaURL];
}

- (void)setAnswerAIsFavored:(BOOL)answerAIsFavored
{
    _answerAIsFavored = answerAIsFavored;
    [self.answerAResultView setColor:answerAIsFavored ? [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor]];
}

- (void)setAnswerBIsFavored:(BOOL)answerBIsFavored
{
    _answerBIsFavored = answerBIsFavored;
    [self.answerBResultView setColor:answerBIsFavored ? [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor]];
}

#pragma mark - Public Methods

- (void)setAnswerAPercentage:(CGFloat)answerAPercentage
                    animated:(BOOL)animated
{
    [self.answerAResultView setProgress:answerAPercentage
                               animated:animated];
}

- (void)setAnswerBPercentage:(CGFloat)answerBPercentage
                    animated:(BOOL)animated
{
    [self.answerBResultView setProgress:answerBPercentage
                               animated:animated];
}

- (void)setAnswerAIsVideowithVideoURL:(NSURL *)videoURL
{
    self.answerAIsVideo = YES;
    
    [self.answerAButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    self.aVideoPlayerViewController = [self videoPlayerViewControllerWithItemURL:videoURL
                                                                  containingView:self.answerAVideoPlayerContainer];
    [self.answerAVideoPlayerContainer addSubview:self.aVideoPlayerViewController.view];
}

- (void)setAnswerBIsVideowithVideoURL:(NSURL *)videoURL
{
    self.answerBIsVideo = YES;
    
    [self.answerBButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    
    self.bVideoPlayerViewController = [self videoPlayerViewControllerWithItemURL:videoURL
                                                                  containingView:self.answerBVideoPlayerContainer];
    [self.answerBVideoPlayerContainer addSubview:self.bVideoPlayerViewController.view];
}

- (VCVideoPlayerViewController *)videoPlayerViewControllerWithItemURL:(NSURL *)itemURL
                                                       containingView:(UIView *)container
{
    VCVideoPlayerViewController *videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil
                                                                                                           bundle:nil];
    
    videoPlayerViewController.delegate = self;
    videoPlayerViewController.view.frame = container.bounds;
    videoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    videoPlayerViewController.shouldShowToolbar = NO;
    videoPlayerViewController.view.contentMode = UIViewContentModeScaleAspectFill;
    videoPlayerViewController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPlayerViewController.shouldLoop = YES;
    [videoPlayerViewController setItemURL:itemURL];

    [container addSubview:videoPlayerViewController.view];
    
    return videoPlayerViewController;
}

#pragma mark - IBActions

- (IBAction)pressedAnswerAButton:(id)sender
{
    [self.contentView bringSubviewToFront:self.answerAContainer];
    self.answerAThumbnail.hidden = self.answerAIsVideo;
    [self shareAnimationCurveWithAnimations:^
     {
         self.answerAContainerViewWidth.constant = (self.answerAContainerViewWidth.constant ==  CGRectGetWidth(self.contentView.bounds)) ? (CGRectGetWidth(self.contentView.bounds)/2)-1 : CGRectGetWidth(self.contentView.bounds);
         [self.contentView layoutIfNeeded];
     }
                             withCompletion:^
     {
         if (self.answerAContainerViewWidth.constant == (CGRectGetWidth(self.contentView.bounds)/2)-1)
         {
             [self.aVideoPlayerViewController.player pause];
             if (self.answerAIsVideo)
             {
                 [self.answerAButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
             }
         }
         else
         {
             [self.aVideoPlayerViewController.player play];
             [self.answerAButton setImage:nil forState:UIControlStateNormal];
         }
     }];
}

- (IBAction)pressedAnswerBButton:(id)sender
{
    [self.contentView bringSubviewToFront:self.answerBContainer];
    self.answerBThumbnail.hidden = self.answerBIsVideo;
    [self shareAnimationCurveWithAnimations:^
    {
         self.answerBContainerViewWidth.constant = (self.answerBContainerViewWidth.constant ==  CGRectGetWidth(self.contentView.bounds)) ? (CGRectGetWidth(self.contentView.bounds)/2)-1 : CGRectGetWidth(self.contentView.bounds);
        [self.contentView layoutIfNeeded];
    }
     withCompletion:^
    {
        if (self.answerBContainerViewWidth.constant == (CGRectGetWidth(self.contentView.bounds)/2)-1)
        {
            [self.bVideoPlayerViewController.player pause];
            if (self.answerBIsVideo)
            {
                [self.answerBButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [self.bVideoPlayerViewController.player play];
            [self.answerBButton setImage:nil forState:UIControlStateNormal];
        }
    }];
}

- (void)shareAnimationCurveWithAnimations:(void (^)(void))animations
                           withCompletion:(void (^)(void))completion
{
    [self.contentView bringSubviewToFront:self.answerAResultView];
    [self.contentView bringSubviewToFront:self.answerBResultView];
    [self.contentView layoutIfNeeded];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         if (animations)
         {
             animations();
         }
     }
                     completion:^(BOOL finished)
     {
         if (completion && finished)
         {
             completion();
         }
     }];
}

@end
