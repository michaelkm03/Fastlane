//
//  VContentPollCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollCell.h"

static const CGFloat kDesiredPollCellHeight = 214.0f;

@interface VContentPollCell ()

@property (weak, nonatomic) IBOutlet UIImageView *answerAThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *answerAPlayButton;
@property (weak, nonatomic) IBOutlet UIImageView *answerBThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *answerBPlayButton;

@end

@implementation VContentPollCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kDesiredPollCellHeight);
}

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

@end
