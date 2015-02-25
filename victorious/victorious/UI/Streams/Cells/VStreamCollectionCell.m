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

#import "VUserProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIImage+ImageCreation.h"

#import "VConstants.h"

#import "VCommentCell.h"
#import "VStreamCellActionView.h"

#import "UIImageView+VLoadingAnimations.h"
#import "NSString+VParseHelp.h"

#import "VSettingManager.h"

#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"
#import "UIView+Autolayout.h"
#import "VVideoView.h"

@interface VStreamCollectionCell() <VSequenceActionsDelegate, CCHLinkTextViewDelegate, VVideoViewDelegtae>

@property (nonatomic, weak) IBOutlet UIImageView *playImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playBackgroundImageView;

@property (nonatomic, weak) IBOutlet CCHLinkTextView *captionTextView;

@property (nonatomic, weak) IBOutlet VStreamCellActionView *actionView;
@property (nonatomic, weak) IBOutlet UIImageView *bottomGradient;

@property (nonatomic, weak) IBOutlet VVideoView *videoPlayerView;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, strong) VAsset *videoAsset;
@property (nonatomic, assign) BOOL isPlayButtonVisible;

@property (nonatomic, readonly) BOOL canPlayVideo;

@end

static const CGFloat kTemplateCYRatio = 1.3079470199; // 395/302
static const CGFloat kTemplateCXRatio = 0.94375; // 320/302
static const CGFloat kDescriptionBuffer = 18.0;
static const CGFloat kTextViewInset = 20.0f; //Needs to be sum of textview inset from left and right
static const CGFloat kTextViewLineFragmentPadding = 5.0f; //Since we don't update linefragment padding on the uitextview, this is the default 5.0

@implementation VStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    
    self.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    NSString *headerNibName = isTemplateC ? @"VStreamCellHeaderView-C" : @"VStreamCellHeaderView";
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:headerNibName owner:self options:nil] objectAtIndex:0];
    [self.streamCellHeaderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.streamCellHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:self.streamCellHeaderView];
    NSDictionary *views = @{ @"header":self.streamCellHeaderView };
    CGFloat height = CGRectGetHeight(self.streamCellHeaderView.bounds);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[header]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[header(height)]"
                                                                 options:0
                                                                 metrics:@{ @"height":@(height) }
                                                                   views:views]];
    self.streamCellHeaderView.delegate = self;
}

- (void)text:(NSString *)text tappedInTextView:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(hashTag:tappedFromSequence:fromView:)])
    {
        [self.delegate hashTag:text tappedFromSequence:self.sequence fromView:self];
    }
}

- (void)setDelegate:(id<VSequenceActionsDelegate>)delegate
{
    _delegate = delegate;
    self.actionView.delegate = delegate;
}

- (void)setDescriptionText:(NSString *)text
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    if (self.sequence.nameEmbeddedInContent.boolValue == NO)
    {
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[VStreamCollectionCell sequenceDescriptionAttributes]];
        self.captionTextView.linkDelegate = self;
        if ( !isTemplateC )
        {
            self.captionTextView.textContainer.maximumNumberOfLines = 3;
        }
        self.captionTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        self.captionTextView.attributedText = newAttributedCellText;
    }
    else
    {
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:@""];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self pauseVideo];
    
    self.videoPlayerView.alpha = 0.0f;
    
    self.videoAsset = nil;
}

- (CGRect)mediaContentFrame
{
    return self.contentContainer.frame;
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
    
    self.captionTextView.hidden = self.sequence.nameEmbeddedInContent.boolValue || self.sequence.name.length == 0;
    
    [self setupActionBar];
    
    self.bottomGradient.hidden = (sequence.nameEmbeddedInContent != nil) ? [sequence.nameEmbeddedInContent boolValue] : NO;
    
    if ( [sequence isVideo] )
    {
        VAsset *asset = [self.sequence.firstNode mp4Asset];
        if ( asset.streamAutoplay.boolValue )
        {
            self.videoAsset = asset;
            self.isPlayButtonVisible = NO;
            [self.videoPlayerView setItemURL:[NSURL URLWithString:self.videoAsset.data]
                                        loop:self.videoAsset.loop.boolValue
                               audioMuted:self.videoAsset.audioMuted.boolValue];
        }
        else
        {
            self.isPlayButtonVisible = YES;
        }
    }
    else
    {
        self.isPlayButtonVisible = NO;
    }
}

- (BOOL)canPlayVideo
{
    return self.videoAsset != nil;
}

- (void)playVideo
{
    if ( self.canPlayVideo )
    {
        [self.videoPlayerView play];
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^void
         {
             self.videoPlayerView.alpha = 1.0f;
         }
                         completion:nil];
    }
}

- (void)pauseVideo
{
    if ( self.canPlayVideo  )
    {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^void
         {
             self.videoPlayerView.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [self.videoPlayerView pause];
         }];
    }
}

- (void)setIsPlayButtonVisible:(BOOL)isPlayButtonVisible
{
    _isPlayButtonVisible = isPlayButtonVisible;
    self.playImageView.hidden = self.playBackgroundImageView.hidden = !isPlayButtonVisible;
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    [self.actionView addShareButton];
    if ( [self.sequence canRemix] )
    {
        [self.actionView addRemixButton];
    }
    if ( [self.sequence canRepost] )
    {
        [self.actionView addRepostButton];
    }
    [self.actionView addFlagButton];
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
    
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        //Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:actual.width - kTextViewInset - kTextViewLineFragmentPadding * 2
                                             andAttributes:[self sequenceDescriptionAttributes]];
        actual.height += textSize.height + kDescriptionBuffer;
    }
    
    return actual;
}

+ (NSDictionary *)sequenceDescriptionAttributes
{
    const BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    NSString *colorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    attributes[ NSForegroundColorAttributeName ] = [[VThemeManager sharedThemeManager] themedColorForKey:colorKey];
    
    if ( isTemplateC )
    {
        attributes[ NSFontAttributeName ] = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    }
    else
    {
        attributes[ NSFontAttributeName ] = [[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font] fontWithSize:19];
        
        paragraphStyle.maximumLineHeight = 25;
        paragraphStyle.minimumLineHeight = 25;
        
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowBlurRadius:4.0f];
        [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
        [shadow setShadowOffset:CGSizeMake(0, 0)];
        attributes[NSShadowAttributeName] = shadow;
    }
    
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if ([self.delegate respondsToSelector:@selector(hashTag:tappedFromSequence:fromView:)])
    {
        [self.delegate hashTag:value
            tappedFromSequence:self.sequence
                      fromView:self];
    }
}

#pragma mark - VVideoViewDelegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    [self playVideo];
}

@end
