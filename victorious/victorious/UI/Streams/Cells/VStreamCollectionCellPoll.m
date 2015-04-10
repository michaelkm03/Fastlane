//
//  VStreamCollectionCellPoll.m
//  victorious
//
//  Created by Will Long on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellPoll.h"

#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"

#import "NSString+VParseHelp.h"

#import "VSettingManager.h"

static const CGFloat kPollCellHeightRatio = 0.66875f; //from spec, 214 height for 320 width
static const NSUInteger kPollCellCaptionLineLimit = 2;

@interface VStreamCollectionCellPoll ()

@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@end

@implementation VStreamCollectionCellPoll

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
    
    [self.previewImageView fadeInImageAtURL:self.firstAssetUrl
                           placeholderImage:nil];
    
    [self.previewImageTwo fadeInImageAtURL:self.secondAssetUrl
                          placeholderImage:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake(width, width * kPollCellHeightRatio);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    return [self desiredSizeWithCollectionViewBounds:bounds];
}

- (NSUInteger)maxCaptionLines
{
    return kPollCellCaptionLineLimit;
}

@end
