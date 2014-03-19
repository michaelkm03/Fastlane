//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"

#import "VObjectManager+Sequence.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "NSString+VParseHelp.h"

static NSString* kOrIconImage = @"orIconImage";

@import MediaPlayer;

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer* firstAnswer;
@property (nonatomic, weak) VAnswer* secondAnswer;

@property (nonatomic, copy) NSURL* firstAssetUrl;
@property (nonatomic, copy) NSURL* secondAssetUrl;

@end

@implementation VStreamPollCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSMutableArray* animationImages = [[NSMutableArray alloc] initWithCapacity:40];
    for (int i = 1; i < 40; i++)
    {
        if ( i > 9 && i < 35)
        {
            [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@"10-34"]]];
        }
        else
        {
            [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@(i).stringValue]]];
        }
    }
    [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@(1).stringValue]]];
    
    self.animationImage.animationImages = animationImages;
    self.animationImage.animationDuration = 1.2f;
    self.animationImage.animationRepeatCount = 1;
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupMedia];
    [self checkIfAnswered];
}

- (void)setupMedia
{
    VAsset* firstAsset = [[self.sequence firstNode] firstAsset];
    if (firstAsset)
    {
        self.firstAssetUrl = [firstAsset.data convertToPreviewImageURL];
    }
    else
    {
        self.firstAssetUrl = [self.firstAnswer.mediaUrl convertToPreviewImageURL];
        self.secondAssetUrl = [self.secondAnswer.mediaUrl convertToPreviewImageURL];
    }
    [self.previewImageView setImageWithURL:self.firstAssetUrl placeholderImage:nil];
    [self.previewImageTwo setImageWithURL:self.secondAssetUrl placeholderImage:nil];
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
//            [self showResultsForAnswerId:result.answerId];
        }
    }
}

- (void)firstAnimation
{
    if (self.animating)
    {
        [self.animationImage startAnimating];
        [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:5.0f];
    }
}

@end
