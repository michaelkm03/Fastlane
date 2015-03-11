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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentsLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *interLabelSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionTextViewTopConstraint;

@property (nonatomic, strong) VAsset *videoAsset;
@property (nonatomic, assign) BOOL isPlayButtonVisible;

@property (nonatomic, readonly) BOOL canPlayVideo;

@end

//IMPORTANT: these template C constants much match up with the heights of values from the VStreamCollectionCell-C xib
static const CGFloat kTemplateCXRatio = 0.94375f; // 320/302
static const CGFloat kTemplateCHeaderHeight = 50.0f;
static const CGFloat kTemplateCActionViewHeight = 41.0f;
static const CGFloat kTemplateCTextViewInset = 22.0f; //Needs to be sum of textview inset from left and right

static const CGFloat kTemplateCTextViewLineFragmentPadding = 0.0f; //This value will be used to update the lineFragmentPadding of the captionTextView and serve as reference in size calculations

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kTemplateCTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it
const CGFloat kTemplateCTextSeparatorHeight = 6.0f; //This represents the space between the label and textView. It's slightly smaller than the those separating the label and textview from their respective bottom and top to neighboring views so that the centers of words are better aligned

@implementation VStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    BOOL isTemplateC = [VStreamCollectionCell isTemplateC];
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
    self.commentsLabel.font = [[VStreamCollectionCell sequenceCommentCountAttributes] objectForKey:NSFontAttributeName];
    self.captionTextView.textContainer.lineFragmentPadding = kTemplateCTextViewLineFragmentPadding;
    self.commentsLeftConstraint.constant = - kTemplateCTextViewLineFragmentPadding;
    
    self.captionTextView.textContainerInset = UIEdgeInsetsZero;
    self.streamCellHeaderView.delegate = self;
    
    self.commentLabelBottomConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
    self.captionTextViewTopConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
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
    BOOL hasText = !self.sequence.nameEmbeddedInContent.boolValue;
    if ( hasText )
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
    
    //Remove the space between label and textView if the textView is empty
    self.interLabelSpaceConstraint.constant = !(hasText && text.length > 0) ? 0 : kTemplateCTextSeparatorHeight;
}

- (void)reloadCommentsCount
{
    if ( [VStreamCollectionCell isTemplateC] )
    {
        NSNumber *commentCount = [self.sequence commentCount];
        NSString *commentsString = [NSString stringWithFormat:@"%@ %@", [commentCount stringValue], [commentCount integerValue] == 1 ? NSLocalizedString(@"Comment", @"") : NSLocalizedString(@"Comments", @"")];
        [self.commentsLabel setText:commentsString];
        self.commentHeightConstraint.constant = [commentsString sizeWithAttributes:@{ NSFontAttributeName : self.commentsLabel.font }].height;
    }
    else
    {
        [self.streamCellHeaderView reloadCommentsCount];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self pauseVideo];
    
    self.videoPlayerView.alpha = 0.0f;
    
    self.interLabelSpaceConstraint.constant = kTemplateCTextSeparatorHeight;
    
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
    
    if ( [VStreamCollectionCell isTemplateC] )
    {
        [self reloadCommentsCount];
    }
    
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
    [self.actionView addMoreButton];
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
    CGFloat width = CGRectGetWidth(bounds);
    if ( !isTemplateC )
    {
        return CGSizeMake(width, width);
    }
    
    width *= kTemplateCXRatio;
    CGFloat height = width + kTemplateCHeaderHeight + kTemplateCActionViewHeight + kTemplateCTextNeighboringViewSeparatorHeight * 2.0f + kTemplateCTextSeparatorHeight; //Width represents the desired media height, there are 2 neighboring separators (top to textview and bottom to comment label) in addition to one constraint between the comment count label and the textview.
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];
    
    if ( ![self isTemplateC] )
    {
        return actual;
    }
    
    CGFloat width = actual.width - kTemplateCTextViewInset - kTemplateCTextViewLineFragmentPadding * 2;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        //Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributes]];
        actual.height += textSize.height;
    }
    else
    {
        //We have no text to display, remove the separator height from our calculation
        actual.height -= kTemplateCTextSeparatorHeight;
    }
    
    CGSize textSize = [[sequence.commentCount stringValue] frameSizeForWidth:width
                                                               andAttributes:[self sequenceCommentCountAttributes]];
    actual.height += textSize.height;
    
    return actual;
}

+ (NSDictionary *)sequenceCommentCountAttributes
{
    return @{ NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] };
}

+ (NSDictionary *)sequenceDescriptionAttributes
{
    const BOOL isTemplateC = [self isTemplateC];
    
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

+ (BOOL)isTemplateC
{
    return [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
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
