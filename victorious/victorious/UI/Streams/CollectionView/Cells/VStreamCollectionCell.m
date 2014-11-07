//
//  VStreamCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

#import "VStreamCellHeaderView.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"

#import "VHashTags.h"

#import "VUserProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"

#import "VConstants.h"

#import "VCommentCell.h"
#import "VStreamCellActionView.h"

#import "UIImageView+VLoadingAnimations.h"
#import "NSString+VParseHelp.h"

#import "VSettingManager.h"

@interface VStreamCollectionCell() <VSequenceActionsDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *playImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playBackgroundImageView;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet VStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionBufferConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBufferConstraint;

@property (nonatomic, strong) NSArray *hashTagRanges;

@end

static const CGFloat kTemplateCYRatio = 1.34768211921; //407/302
static const CGFloat kTemplateCXRatio = 0.94375;
static const CGFloat kDescriptionBuffer = 15.0;

@implementation VStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    

    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    if (!isTemplateC)
    {
        self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self.descriptionLabel.font = [VStreamCollectionCell sequenceDescriptionAttributes][NSFontAttributeName];
    
    NSString *headerNibName = isTemplateC ? @"VStreamCellHeaderView-C" : @"VStreamCellHeaderView";
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:headerNibName owner:self options:nil] objectAtIndex:0];
    [self addSubview:self.streamCellHeaderView];
    self.streamCellHeaderView.delegate = self;
}

- (void)setDelegate:(id<VSequenceActionsDelegate>)delegate
{
    _delegate = delegate;
    self.actionView.delegate = delegate;
}

- (void)setDescriptionText:(NSString *)text
{
    if (!self.sequence.nameEmbeddedInContent.boolValue)
    {
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[VStreamCollectionCell sequenceDescriptionAttributes]];
        self.hashTagRanges = [VHashTags detectHashTags:text];
        
        if ([self.hashTagRanges count] > 0)
        {
            [VHashTags formatHashTagsInString:newAttributedCellText
                                withTagRanges:self.hashTagRanges
                                   attributes:@{NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]}];
        }
        
        self.descriptionLabel.attributedText = newAttributedCellText;
        
        self.descriptionBufferConstraint.constant = self.actionViewBufferConstraint.constant;
    }
    else
    {
        self.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];
        
        self.descriptionBufferConstraint.constant = 0;
    }
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.actionView.sequence = sequence;
    
    [self.streamCellHeaderView setSequence:self.sequence];
    [self.streamCellHeaderView setParentViewController:self.parentViewController];
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[_sequence.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];

    [self setDescriptionText:self.sequence.name];
    
    self.descriptionLabel.hidden = self.sequence.nameEmbeddedInContent.boolValue;
    
    self.playImageView.hidden = self.playBackgroundImageView.hidden = ![sequence isVideo];
    
    [self setupActionBar];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    [self.actionView addShareButton];
    if (![self.sequence isPoll])
    {
        [self.actionView addRemixButton];
    }
    [self.actionView addRepostButton];
    [self.actionView addFlagButton];
    [self.actionView layoutIfNeeded];
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (BOOL)remixRepostCheck:(NSString *)sequenceCategory
{
    if ([sequenceCategory rangeOfString:@"remix"].location == NSNotFound && [sequenceCategory rangeOfString:@"repost"].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (void)hideOverlays
{
    self.overlayView.alpha = 0;
    self.shadeView.alpha = 0;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height);
}

- (void)showOverlays
{
    self.overlayView.alpha = 1;
    self.shadeView.alpha = 1;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y);
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.delegate willCommentOnSequence:self.sequence fromView:self];
    }
}

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(selectedUserOnSequence:fromView:)])
    {
        [self.delegate selectedUserOnSequence:self.sequence fromView:self];
    }
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    NSString *reuseID = NSStringFromClass([self class]);
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        reuseID = [reuseID stringByAppendingString:@"-C"];
    }
    return reuseID;
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:[self suggestedReuseIdentifier]
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    CGFloat yRatio = isTemplateC ? kTemplateCYRatio : 1;
    CGFloat xRatio = isTemplateC ? kTemplateCXRatio : 1;
    CGFloat width = CGRectGetWidth(bounds) * xRatio;
    return CGSizeMake(width, width * yRatio);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];
    if (![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return actual;
    }
    
    if (!sequence.nameEmbeddedInContent.boolValue)
    {
        CGSize textSize = [sequence.name frameSizeForWidth:actual.width - kDescriptionBuffer * 2
                                             andAttributes:[self sequenceDescriptionAttributes]];
        actual.height = actual.height + textSize.height + kDescriptionBuffer;
    }
    
    return actual;
}

+ (NSDictionary *)sequenceDescriptionAttributes
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *colorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    
    //TODO: Remvoe this hardcoded font size
    NSMutableDictionary *attributes = [@{
                                         NSForegroundColorAttributeName:  [[VThemeManager sharedThemeManager] themedColorForKey:colorKey],
                                         NSFontAttributeName: [[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font] fontWithSize:19],
                                         } mutableCopy];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.maximumLineHeight = 25;
    paragraphStyle.minimumLineHeight = 25;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    if (!isTemplateC)
    {
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowBlurRadius:4.0f];
        [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
        [shadow setShadowOffset:CGSizeMake(0, 0)];
        attributes[NSShadowAttributeName] = shadow;
    }
    return [attributes copy];
}

@end
