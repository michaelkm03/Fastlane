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
@property (nonatomic, weak) IBOutlet UIButton *answerAPlayButton;
@property (nonatomic, weak) IBOutlet UIImageView *answerBThumbnail;
@property (nonatomic, weak) IBOutlet UIButton *answerBPlayButton;
@property (nonatomic, weak) IBOutlet VResultView *answerAResultView;
@property (nonatomic, weak) IBOutlet VResultView *answerBResultView;

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
    self.answerAPlayButton.hidden = !answerAIsVideo;
}

- (void)setAnswerBThumbnailMediaURL:(NSURL *)answerBThumbnailMediaURL
{
    _answerBThumbnailMediaURL = [answerBThumbnailMediaURL copy];
    [self.answerBThumbnail setImageWithURL:_answerBThumbnailMediaURL];
}

- (void)setAnswerBIsVideo:(BOOL)answerBIsVideo
{
    _answerBIsVideo = answerBIsVideo;
    self.answerBPlayButton.hidden = !answerBIsVideo;
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

@end
