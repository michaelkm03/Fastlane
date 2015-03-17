//
//  VInsetStreamCollectionCellPoll.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VAnswer.h"
#import "VDependencyManager.h"
#import "VInsetStreamCollectionCellPoll.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VStreamCellActionView.h"

// IMPORTANT: these constants much match up with the heights of values from the VInsetStreamCollectionCellPoll.xib
static const CGFloat kPollCellWidthRatio = 0.94375f; // 320/302
static const CGFloat kPollContentRatio = 0.6688741722f; // 202/302
static const CGFloat kHeaderHeight = 50.0f;
static const CGFloat kActionViewHeight = 41.0f;
static const CGFloat kTextNeighboringViewSeparatorHeight = 10.0f; // This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VInsetStreamCollectionCellPoll ()

@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@end

@implementation VInsetStreamCollectionCellPoll

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray *answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupMedia];
}

- (void)setupMedia
{
    self.firstAssetUrl = [NSURL URLWithString: self.firstAnswer.thumbnailUrl];
    self.secondAssetUrl = [NSURL URLWithString:self.secondAnswer.thumbnailUrl];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]];
    
    [self.previewImageView fadeInImageAtURL:self.firstAssetUrl
                           placeholderImage:placeholderImage];
    
    [self.previewImageTwo fadeInImageAtURL:self.secondAssetUrl
                          placeholderImage:placeholderImage];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = floorf(CGRectGetWidth(bounds) * kPollCellWidthRatio);
    CGFloat height = floorf(width * kPollContentRatio + kHeaderHeight + kTextNeighboringViewSeparatorHeight * 2.0f + kActionViewHeight); // width * kTemplateCPollContentRatio represents the desired media height
    return CGSizeMake(width, height);
}

@end
