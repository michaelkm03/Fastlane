//
//  VInsetStreamCollectionCell.m
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

#import "VInsetStreamCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VImageAsset+Fetcher.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VSequencePreviewView.h"
#import "UIView+AutoLayout.h"
#import "NSString+VParseHelp.h"
#import "VInsetActionView.h"
#import "VHashTagTextView.h"
#import "VStreamCellHeader.h"
#import "VCompatibility.h"
#import "VStreamCollectionViewController.h"
#import "VSequenceCountsTextView.h"
#import "VCellSizeCollection.h"
#import "VCellSizingUserInfoKeys.h"
#import "VActionButtonAnimationController.h"

static const CGFloat kInsetCellHeaderHeight         = 50.0f;
static const CGFloat kInsetCellActionViewHeight     = 41.0f;
static const CGFloat kCountsTextViewMinHeight       = 20.0f;
static const CGFloat kMaxCaptionHeight              = 80.0f;
static const UIEdgeInsets kTextMargins              = { 10.0f, 10.0f, 0.0f, 10.0f };
static const UIEdgeInsets kCaptionInsets            = { 4.0, 0.0, 4.0, 0.0  };

@interface VInsetStreamCollectionCell () <CCHLinkTextViewDelegate, VSequenceCountsTextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VStreamCellHeader *header;
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) UIView *dimmingContainer;
@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VHashTagTextView *captionTextView;
@property (nonatomic, strong) VSequenceCountsTextView *countsTextView;
@property (nonatomic, strong) VInsetActionView *actionView;
@property (nonatomic, strong) NSLayoutConstraint *previewViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *countsVerticalSpacing;
@property (nonatomic, strong) VActionButtonAnimationController *actionButtonAnimationController;
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation VInsetStreamCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _actionButtonAnimationController = [[VActionButtonAnimationController alloc] init];
    
    // Header at the top, left to right and kInsetCellHeaderHeight
    _header = [[VStreamCellHeader alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_header];
    [self.contentView v_addPinToLeadingTrailingToSubview:_header];
    [self.contentView v_addPinToTopToSubview:_header];
    [_header v_addHeightConstraint:kInsetCellHeaderHeight];
    
    // Next preview container
    _previewContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _previewContainer.clipsToBounds = YES;
    [self.contentView addSubview:_previewContainer];
    [self.contentView v_addPinToLeadingTrailingToSubview:_previewContainer];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_header][_previewContainer]"
                                                                             options:kNilOptions
                                                                             metrics:0
                                                                               views:NSDictionaryOfVariableBindings(_header, _previewContainer)]];
    
    // Dimming view
    _dimmingContainer = [UIView new];
    _dimmingContainer.alpha = 0;
    _dimmingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewContainer addSubview:_dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:_dimmingContainer];

    // Now the caption text view
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@""];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    [layoutManager addTextContainer:textContainer];
    textContainer.heightTracksTextView = YES;
    textContainer.widthTracksTextView = YES;
    textContainer.lineFragmentPadding = 0.0f;
    _captionTextView = [[VHashTagTextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    _captionTextView.scrollEnabled = NO;
    _captionTextView.editable = NO;
    _captionTextView.textContainerInset = kCaptionInsets;
    _captionTextView.linkDelegate = self;
    _captionTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_captionTextView];
    [self.contentView v_addPinToLeadingTrailingToSubview:_captionTextView  leading:kTextMargins.left trailing:kTextMargins.right];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_previewContainer
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0f
                                                                  constant:kTextMargins.top]];
    [_captionTextView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kMaxCaptionHeight]];
    
    _actionView = [[VInsetActionView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_actionView];
    [self.contentView v_addPinToLeadingTrailingToSubview:_actionView];
    [self.contentView v_addPinToBottomToSubview:_actionView];
    [_actionView v_addHeightConstraint:kInsetCellActionViewHeight];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_separatorView];
    _separatorView.backgroundColor = [UIColor clearColor];
    [_separatorView v_addHeightConstraint:1.0f];
    [self.contentView v_addPinToLeadingTrailingToSubview:_separatorView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_separatorView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    
    // Comments and likes count
    _countsTextView = [[VSequenceCountsTextView alloc] init];
    _countsTextView.contentInset = UIEdgeInsetsMake( 0, -4, 0, 0 );
    _countsTextView.textSelectionDelegate = self;
    [self.contentView addSubview:_countsTextView];
    _countsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_countsTextView addConstraint:[NSLayoutConstraint constraintWithItem:_countsTextView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:kCountsTextViewMinHeight]];
    [self.contentView v_addPinToLeadingTrailingToSubview:_countsTextView leading:kTextMargins.left trailing:kTextMargins.right];
    _countsVerticalSpacing = [NSLayoutConstraint constraintWithItem:_countsTextView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_captionTextView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0];
    [self.contentView addConstraint:_countsVerticalSpacing];
    
    // Fixes constraint errors when resizing for certain aspect ratios
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
}

+ (VCellSizeCollection *)cellLayoutCollection
{
    static VCellSizeCollection *collection;
    if ( collection == nil )
    {
        collection = [[VCellSizeCollection alloc] init];
        [collection addComponentWithConstantSize:CGSizeMake( 0.0f, kInsetCellHeaderHeight)];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             return CGSizeMake( 0.0f, size.width  / [sequence previewAssetAspectRatio] );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             CGFloat textHeight = 0.0f;
             if ( sequence.name.length > 0 )
             {
                 VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
                 CGFloat textWidth = size.width - kTextMargins.left - kTextMargins.right;
                 NSDictionary *attributes = [self sequenceDescriptionAttributesWithDependencyManager:dependencyManager];
                 textHeight = VCEIL( [sequence.name frameSizeForWidth:textWidth andAttributes:attributes].height );
                 textHeight += kCaptionInsets.bottom + kCaptionInsets.top;
             }
             return CGSizeMake( 0.0f, textHeight );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             CGFloat height = sequence.name.length > 0 ? kTextMargins.top : 0.0f;
             return CGSizeMake( 0.0f, height );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             CGFloat textWidth = size.width - kTextMargins.left - kTextMargins.right;
             VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
             NSDictionary *attributes = [[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager];
             
             // FIXME: The use of "V" is just to get a good size for *something* in this text field since
             // we can't know what the actual text for the label is in a static method
             return CGSizeMake( 0.0f, MAX( kCountsTextViewMinHeight, [@"V" frameSizeForWidth:textWidth andAttributes:attributes].height ) );
         }];
        [collection addComponentWithConstantSize:CGSizeMake( 0.0f, kInsetCellActionViewHeight + kTextMargins.top)];
    }
    return collection;
}

- (void)handleTapGestureForCommentLabel:(UIGestureRecognizer *)recognizer
{
    UIResponder<VSequenceActionsDelegate> *targetForCommentLabelSelection = [self targetForAction:@selector(willCommentOnSequence:fromView:)
                                                                                       withSender:self];
    NSAssert(targetForCommentLabelSelection != nil, @"We need an object in the responder chain for hash tag selection.!");
    
    [targetForCommentLabelSelection willCommentOnSequence:self.sequence fromView:self];
}

#pragma mark - UIView

- (void)updateConstraints
{
    // Add new height constraint for preview container to account for aspect ratio of preview asset
    CGFloat aspectRatio = [self.sequence previewAssetAspectRatio];
    NSLayoutConstraint *heightToWidth = [NSLayoutConstraint constraintWithItem:self.previewContainer
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.previewContainer
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:(1 / aspectRatio)
                                                                      constant:0.0f];
    [self.contentView addConstraint:heightToWidth];
    self.previewViewHeightConstraint = heightToWidth;
    
    [super updateConstraints];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    if ([self.actionView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.actionView setDependencyManager:dependencyManager];
    }
    if ([self.header respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.header setDependencyManager:dependencyManager];
    }
    if ([self.captionTextView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.captionTextView setDependencyManager:dependencyManager];
    }
    
    [self.countsTextView setTextHighlightAttributes:[[self class] sequenceCountsActiveAttributesWithDependencyManager:dependencyManager]];
    [self.countsTextView setTextAttributes:[[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager]];
    [self.separatorView setBackgroundColor:[dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey]];
}

+ (NSDictionary *)sequenceCountsActiveAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    return @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
}

+ (NSDictionary *)sequenceCountsAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    return @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.header.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    self.actionView.sequence = sequence;
    [self.contentView removeConstraint:self.previewViewHeightConstraint];
    [self setNeedsUpdateConstraints];
    
    [self updateCountsTextViewForSequence:sequence];
    [self.actionButtonAnimationController setButton:self.actionView.likeButton
                                           selected:sequence.isLikedByMainUser.boolValue];
    [self.actionButtonAnimationController setButton:self.actionView.repostButton
                                           selected:sequence.hasReposted.boolValue];
}

- (void)updateCountsTextViewForSequence:(VSequence *)sequence
{
    const BOOL canLike = [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue;
    
    self.countsTextView.hideComments = !sequence.permissions.canComment;
    self.countsTextView.hideLikes = !canLike;
    [self.countsTextView setCommentsCount:sequence.commentCount.integerValue];
    [self.countsTextView setLikesCount:sequence.likeCount.integerValue];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.dependencyManager setHighlighted:highlighted onHost:self];
}

#pragma mark - Internal Methods

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ([self.previewView canHandleSequence:sequence])
    {
        [self.previewView setSequence:sequence];
        return;
    }

    [self.previewView removeFromSuperview];
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    if ( sequence.name == nil || sequence.name.length == 0 || self.dependencyManager == nil)
    {
        self.captionTextView.attributedText = nil;
        [self.captionTextView layoutIfNeeded];
        CGFloat spacing = CGRectGetHeight( self.captionTextView.frame );
        self.countsVerticalSpacing.constant = -spacing - kTextMargins.top;
    }
    else
    {
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                              attributes:[VInsetStreamCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
        self.countsVerticalSpacing.constant = 0.0;
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.previewContainer;
}

- (UIView *)backgroundContainerView
{
    return self.contentView;
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *identifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier copy];
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        identifier = [VSequencePreviewView reuseIdentifierForStreamItem:streamItem
                                                         baseIdentifier:identifier
                                                      dependencyManager:dependencyManager];
    }
    return identifier;
}

#pragma mark - NSAttributedString Attributes

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{
             NSForegroundColorAttributeName: [dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
             NSFontAttributeName: [dependencyManager fontForKey:VDependencyManagerParagraphFontKey]
             };
}

#pragma mark - Sizing

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize base = CGSizeMake( CGRectGetWidth(bounds), 0.0 );
    NSDictionary *userInfo = @{ kCellSizingSequenceKey : sequence,
                                VCellSizeCacheKey : [self cacheKeyForSequence:sequence],
                                kCellSizingDependencyManagerKey : dependencyManager };
    return [[[self class] cellLayoutCollection] totalSizeWithBaseSize:base userInfo:userInfo];
}

+ (NSString *)cacheKeyForSequence:(VSequence *)sequence
{
    NSString *name = sequence.name ?: @"";
    NSString *aspectRatioString = [NSString stringWithFormat:@"%.5f", [sequence previewAssetAspectRatio]];
    return [name stringByAppendingString:aspectRatioString];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    UIResponder<VSequenceActionsDelegate> *targetForHashTagSelection = [self targetForAction:@selector(hashTag:tappedFromSequence:fromView:)
                                                                                  withSender:self];
    if (targetForHashTagSelection == nil)
    {
        NSAssert(false, @"We need an object in the responder chain for hash tag selection.!");
    }
    [targetForHashTagSelection hashTag:value
                    tappedFromSequence:self.sequence
                              fromView:self];
}

#pragma mark - VFocusable

@synthesize focusType = _focusType;

- (void)setFocusType:(VFocusType)focusType
{
    _focusType = focusType;
    if ([self.previewView conformsToProtocol:@protocol(VFocusable)])
    {
        [(id <VFocusable>)self.previewView setFocusType:focusType];
    }
}

- (CGRect)contentArea
{
    return self.previewContainer.frame;
}

#pragma mark - VHighlightContainer

- (UIView *)highlightContainerView
{
    return self.dimmingContainer;
}

- (UIView *)highlightActionView
{
    return self.dimmingContainer;
}

#pragma mark - VStreamCellTracking

- (VSequence *)sequenceToTrack
{
    return self.sequence;
}

#pragma mark - VSequenceCountsTextViewDelegate

- (void)likersTextSelected
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willShowLikersForSequence:fromView:) withSender:self];
    NSAssert( responder != nil, @"We need an object in the responder chain for commenting or showing comments.");
    [responder willShowLikersForSequence:self.sequence fromView:self];
}

- (void)commentsTextSelected
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willCommentOnSequence:fromView:) withSender:self];
    NSAssert( responder != nil, @"We need an object in the responder chain for showing likers.");
    [responder willCommentOnSequence:self.sequence fromView:self];
}

@end
