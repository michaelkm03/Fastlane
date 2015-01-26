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

@property (nonatomic, weak, readwrite) IBOutlet UIView *answerAContainer;
@property (nonatomic, weak, readwrite) IBOutlet UIView *answerBContainer;

@property (nonatomic, weak) IBOutlet UIImageView *answerAThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerAButton;
@property (nonatomic, weak) IBOutlet UIImageView *answerBThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerBButton;
@property (nonatomic, weak) IBOutlet VResultView *answerAResultView;
@property (nonatomic, weak) IBOutlet VResultView *answerBResultView;
@property (nonatomic, weak) IBOutlet UIView *answerAVideoPlayerContainer;
@property (nonatomic, weak) IBOutlet UIView *answerBVideoPlayerContainer;

@property (weak, nonatomic) IBOutlet UIView *pollCountContainer;
@property (weak, nonatomic) IBOutlet UILabel *numberOfVotersLabel;

@property (nonatomic, strong) VCVideoPlayerViewController *aVideoPlayerViewController;
@property (nonatomic, strong) VCVideoPlayerViewController *bVideoPlayerViewController;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *answerAContainerViewWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *answerBContainerViewWidth;

@property (nonatomic, assign, readwrite) BOOL answerBIsVideo;
@property (nonatomic, assign, readwrite) BOOL answerAIsVideo;

@property (nonatomic, copy) NSURL *answerAMediaURL;
@property (nonatomic, copy) NSURL *answerBMediaURL;

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
    
    self.numberOfVotersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    
    self.pollCountContainer.layer.cornerRadius = CGRectGetHeight(self.pollCountContainer.bounds) * 0.5f;
}

#pragma mark - Property Accessors

- (void)setNumberOfVotersText:(NSString *)numberOfVotersText
{
    if (!numberOfVotersText || (numberOfVotersText.length == 0))
    {
        return;
    }
    
    self.numberOfVotersLabel.text = numberOfVotersText;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0
                        options:kNilOptions
                     animations:^
    {
        self.pollCountContainer.alpha = 1.0f;
    }
                     completion:nil];
}

- (NSString *)numberOfVotersText
{
    return self.numberOfVotersLabel.text;
}

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

- (UIImage *)answerAPreviewImage
{
    return self.answerAThumbnail.image;
}

- (UIImage *)answerBPreviewImage
{
    return self.answerBThumbnail.image;
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
    self.answerAMediaURL = videoURL;
    
    [self.answerAButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    
    if (self.aVideoPlayerViewController != nil)
    {
        return;
    }
    self.aVideoPlayerViewController = [self videoPlayerViewControllerWithItemURL:videoURL
                                                                  containingView:self.answerAVideoPlayerContainer];
    [self.answerAVideoPlayerContainer addSubview:self.aVideoPlayerViewController.view];
}

- (void)setAnswerBIsVideowithVideoURL:(NSURL *)videoURL
{
    self.answerBIsVideo = YES;
    self.answerBMediaURL = videoURL;
    
    [self.answerBButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    
    if (self.bVideoPlayerViewController != nil)
    {
        return;
    }
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
    [videoPlayerViewController setItemURL:itemURL loop:YES];

    [container addSubview:videoPlayerViewController.view];
    
    return videoPlayerViewController;
}

#pragma mark - IBActions

- (IBAction)pressedAnswerAButton:(id)sender
{
    if (self.onAnswerASelection)
    {
        self.onAnswerASelection(self.answerAIsVideo, self.answerAIsVideo ? self.answerAMediaURL : self.answerAThumbnailMediaURL);
    }
}

- (IBAction)pressedAnswerBButton:(id)sender
{
    if (self.onAnswerBSelection)
    {
        self.onAnswerBSelection(self.answerBIsVideo, self.answerBIsVideo ? self.answerBMediaURL : self.answerBThumbnailMediaURL);
    }
}

- (void)shareAnimationCurveWithAnimations:(void (^)(void))animations
                           withCompletion:(void (^)(void))completion
{
    [self.contentView bringSubviewToFront:self.answerAResultView];
    [self.contentView bringSubviewToFront:self.answerBResultView];
    [self.contentView bringSubviewToFront:self.pollCountContainer];
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
