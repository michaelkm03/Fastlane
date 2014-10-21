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

static const CGFloat kDesiredPollCellHeight = 214.0f;

@interface VContentPollCell ()

@property (nonatomic, weak) IBOutlet UIImageView *answerAThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerAButton;
@property (nonatomic, weak) IBOutlet UIImageView *answerBThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerBButton;
@property (nonatomic, weak) IBOutlet VResultView *answerAResultView;
@property (nonatomic, weak) IBOutlet VResultView *answerBResultView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equalWidthsConstraint;

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

- (void)setAnswerAIsVideo:(BOOL)answerAIsVideo
{
    _answerAIsVideo = answerAIsVideo;
    if (answerAIsVideo)
    {
        [self.answerAButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
}

- (void)setAnswerBThumbnailMediaURL:(NSURL *)answerBThumbnailMediaURL
{
    _answerBThumbnailMediaURL = [answerBThumbnailMediaURL copy];
    [self.answerBThumbnail setImageWithURL:_answerBThumbnailMediaURL];
}

- (void)setAnswerBIsVideo:(BOOL)answerBIsVideo
{
    _answerBIsVideo = answerBIsVideo;
    if (answerBIsVideo)
    {
        [self.answerBButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
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

#pragma mark - IBActions

- (IBAction)pressedAnswerAButton:(id)sender
{
    [self shareAnimationCurveWithAnimations:^
    {
        self.equalWidthsConstraint.constant = (self.equalWidthsConstraint.constant == -CGRectGetWidth(self.contentView.bounds)) ? -2 : -CGRectGetWidth(self.contentView.bounds);
        [self.contentView layoutIfNeeded];
    }];
}

- (IBAction)pressedAnswerBButton:(id)sender
{
    [self shareAnimationCurveWithAnimations:^
    {
        self.equalWidthsConstraint.constant = (self.equalWidthsConstraint.constant == CGRectGetWidth(self.contentView.bounds)) ? 2 : CGRectGetWidth(self.contentView.bounds) ;
        [self.contentView layoutIfNeeded];
    }];
}

- (void)shareAnimationCurveWithAnimations:(void (^)(void))animations
{
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
                     completion:nil];
}

@end
