//
//  VStreamCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

#import "VStreamCellHeaderView.h"
#import "VStreamTableViewController.h"
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

#import "UIImageView+VLoadingAnimations.h"
#import "VSettingManager.h"

@interface VStreamCollectionCell() <VSequenceActionsDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *playImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playBackgroundImageView;

@property (nonatomic, weak) IBOutlet UILabel        *descriptionLabel;

@property (nonatomic) BOOL                          animating;
@property (nonatomic) NSUInteger                    originalHeight;

@property (nonatomic, strong) NSArray               *hashTagRanges;

@end

@implementation VStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    self.originalHeight = self.frame.size.height;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"VStreamCellHeaderView" owner:self options:nil] objectAtIndex:0];
    [self addSubview:self.streamCellHeaderView];
    self.streamCellHeaderView.delegate = self;
}

- (NSDictionary *)attributesForCellText
{
    //TODO: Remvoe this hardcoded font size
    return @{
             NSFontAttributeName: [[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font] fontWithSize:19],
             NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor],
             };
}


- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.streamCellHeaderView setSequence:self.sequence];
    [self.streamCellHeaderView setParentViewController:self.parentViewController];
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[_sequence.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    // Check if being viewed from the User Profile
    if ([self.parentViewController isKindOfClass:[VUserProfileViewController class]])
    {
        [self.streamCellHeaderView setIsFromProfile:YES];
    }
    
    if (!self.sequence.nameEmbeddedInContent.boolValue)
    {
        NSString *text = self.sequence.name;
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[self attributesForCellText]];
        self.hashTagRanges = [VHashTags detectHashTags:text];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = 25;
        paragraphStyle.minimumLineHeight = 25;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowBlurRadius:4.0f];
        [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
        [shadow setShadowOffset:CGSizeMake(0, 0)];
        
        if ([self.hashTagRanges count] > 0)
        {
            [VHashTags formatHashTagsInString:newAttributedCellText
                                withTagRanges:self.hashTagRanges
                                   attributes:@{NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]}];
        }
        [newAttributedCellText addAttribute:NSParagraphStyleAttributeName
                                      value:paragraphStyle
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        [newAttributedCellText addAttribute:NSShadowAttributeName
                                      value:shadow
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        
        self.descriptionLabel.attributedText = newAttributedCellText;
    }
    
    self.descriptionLabel.hidden = self.sequence.nameEmbeddedInContent.boolValue;
    
    self.playImageView.hidden = self.playBackgroundImageView.hidden = ![sequence isVideo];
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
    CGFloat ratio = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? 1.496875 : 1;
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake(width, width * ratio);
}

@end
