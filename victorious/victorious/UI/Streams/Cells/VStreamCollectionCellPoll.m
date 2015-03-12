//
//  VStreamCollectionCellPoll.m
//  victorious
//
//  Created by Will Long on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellPoll.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"

#import "NSString+VParseHelp.h"

#import "VThemeManager.h"
#import "VSettingManager.h"

//IMPORTANT: these template C constants much match up with the heights of values from the VStreamCollectionCellPoll-C xib
static const CGFloat kTemplateCPollCellWidthRatio = 0.94375f; // 320/302
static const CGFloat kTemplateCPollContentRatio = 0.6688741722f; // 202/302
static const CGFloat kTemplateCHeaderHeight = 50.0f;
static const CGFloat kTemplateCActionViewHeight = 41.0f;

static const CGFloat kPollCellHeightRatio = 0.66875f; //from spec, 214 height for 320 width

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
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    
    [self.previewImageView fadeInImageAtURL:self.firstAssetUrl
                           placeholderImage:placeholderImage];
    
    [self.previewImageTwo fadeInImageAtURL:self.secondAssetUrl
                          placeholderImage:placeholderImage];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    CGFloat width = CGRectGetWidth(bounds);
    if ( !isTemplateC )
    {
        return CGSizeMake(width, width * kPollCellHeightRatio);
    }
    
    width = floorf(width * kTemplateCPollCellWidthRatio);
    CGFloat height = floorf(width * kTemplateCPollContentRatio + kTemplateCHeaderHeight + kTemplateCTextNeighboringViewSeparatorHeight * 2.0f + kTemplateCTextSeparatorHeight + kTemplateCActionViewHeight); //width * kTemplateCPollContentRatio represents the desired media height
    return CGSizeMake(width, height);
}

@end
