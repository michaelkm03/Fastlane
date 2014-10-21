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

static const CGFloat kPollCellHeightRatio = 0.66875; //from spec, 214 height for 320 width
static const CGFloat kPollCellHeightRatioC = 1.016; //from spec, 307 height for 302 width
static const CGFloat kPollCellWidthRatioC = 0.94375;

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
    CGFloat yRatio = isTemplateC ? kPollCellHeightRatioC : kPollCellHeightRatio;
    CGFloat xRatio = isTemplateC ? kPollCellWidthRatioC : 1;
    CGFloat width = CGRectGetWidth(bounds) * xRatio;
    return CGSizeMake(width, width * yRatio);
}

@end
