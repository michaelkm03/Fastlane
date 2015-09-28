//
//  VTileOverlayCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIView+AutoLayout.h"
#import "VTileOverlayCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionsDelegate.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VSequencePreviewView.h"
#import "VHashTagTextView.h"
#import "VPassthroughContainerView.h"
#import "VStreamCellHeader.h"
#import "VLinearGradientView.h"
#import "VHashTagTextView.h"
#import "VSequenceExpressionsObserver.h"
#import "VActionButton.h"
#import "VSequenceCountsTextView.h"
#import "NSString+VParseHelp.h"
#import "VCellSizeCollection.h"
#import "VCellSizingUserInfoKeys.h"

@import CCHLinkTextView;

static const UIEdgeInsets kTextInsets           = { 4.0f, 20.0f, 5.0f, 20.0f };
static const CGFloat kHeaderHeight              = 74.0f;
static const CGFloat kGradientAlpha             = 0.3f;
static const CGFloat kShadowAlpha               = 0.5f;
static const CGFloat kCountsTextViewMaxHeight   = 80.0f;
static const CGFloat kButtonWidth               = 44.0f;
static const CGFloat kButtonHeight              = 44.0f;
static const CGFloat kCountsTextViewHeight      = 20.0f;

@interface VTileOverlayCollectionCell () <CCHLinkTextViewDelegate, VSequenceCountsTextViewDelegate>

@property (nonatomic, strong) UIView *loadingBackgroundContainer;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *dimmingContainer;
@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VPassthroughContainerView *overlayContainer;
@property (nonatomic, strong) VLinearGradientView *topGradient;
@property (nonatomic, strong) VLinearGradientView *bottomGradient;
@property (nonatomic, strong) VStreamCellHeader *header;
@property (nonatomic, strong) VHashTagTextView *captionTextView;
@property (nonatomic, strong) VSequenceExpressionsObserver *expressionsObserver;
@property (nonatomic, strong) VActionButton *likeButton;
@property (nonatomic, strong) VActionButton *commentButton;
@property (nonatomic, strong) VSequenceCountsTextView *countsTextView;

@property (nonatomic, strong) NSLayoutConstraint *captionHeight;
@property (nonatomic, strong) NSLayoutConstraint *commentToLikeButtonHorizontalSpacing;
@property (nonatomic, strong) NSLayoutConstraint *likeButtonWidth;
@property (nonatomic, strong) NSLayoutConstraint *contentContainerHeightConstraint;

@end

@implementation VTileOverlayCollectionCell

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
    // Background fills the entire content area
    _loadingBackgroundContainer = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_loadingBackgroundContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_loadingBackgroundContainer];
    
    // Content is overlaid on the loading background
    _contentContainer = [[UIView alloc] initWithFrame:self.contentView.bounds];
    _contentContainer.clipsToBounds = YES;
    [self.contentView addSubview:_contentContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_contentContainer];
    
    // Overlay is overlaid on the content
    _overlayContainer = [[VPassthroughContainerView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_overlayContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_overlayContainer];
    
    // Dimming view
    _dimmingContainer = [UIView new];
    _dimmingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _dimmingContainer.alpha = 0;
    [_overlayContainer addSubview:_dimmingContainer];
    [_overlayContainer v_addFitToParentConstraintsToSubview:_dimmingContainer];
    
    // Within overlay place gradients
    _topGradient = [[VLinearGradientView alloc] initWithFrame:CGRectZero];
    _topGradient.userInteractionEnabled = NO;
    [_overlayContainer addSubview:_topGradient];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_topGradient];
    [_overlayContainer v_addPinToTopToSubview:_topGradient];
    [_topGradient v_addHeightConstraint:kHeaderHeight];
    [_topGradient setColors:@[ [[UIColor blackColor] colorWithAlphaComponent:kGradientAlpha], [UIColor clearColor] ]];
    
    // And the bottom
    _bottomGradient = [[VLinearGradientView alloc] initWithFrame:CGRectZero];
    _bottomGradient.userInteractionEnabled = NO;
    [_overlayContainer addSubview:_bottomGradient];
    [_overlayContainer v_addFitToParentConstraintsToSubview:_bottomGradient];
    [_bottomGradient setColors:@[ [UIColor clearColor], [UIColor blackColor]]];
    
    // Add the header
    _header = [[VStreamCellHeader alloc] initWithFrame:CGRectZero];
    [_overlayContainer addSubview:_header];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_header];
    [_overlayContainer v_addPinToTopToSubview:_header];
    [_header v_addHeightConstraint:kHeaderHeight];
    
    // Comments and likes count
    _countsTextView = [[VSequenceCountsTextView alloc] init];
    _countsTextView.textSelectionDelegate = self;
    _countsTextView.textContainerInset = (UIEdgeInsets){ 0.0f, 16.0f, 0.0f, 10.0f };
    [_countsTextView sizeToFit];
    _countsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_overlayContainer addSubview:_countsTextView];
    [_countsTextView addConstraint:[NSLayoutConstraint constraintWithItem:_countsTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kCountsTextViewHeight]];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_countsTextView];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_countsTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_overlayContainer attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-14.0f]];
    
    // The caption Text view
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
    _captionTextView.linkDelegate = self;
    _captionTextView.textContainerInset = kTextInsets;
    _captionTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    _captionTextView.backgroundColor = [UIColor clearColor];
    [_overlayContainer addSubview:_captionTextView];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_captionTextView];
    _captionHeight = [NSLayoutConstraint constraintWithItem:_captionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kCountsTextViewMaxHeight];
    [_captionTextView addConstraint:_captionHeight];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_countsTextView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    
    // Like button
    UIImage *likeImage = [[UIImage imageNamed:@"A_like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *likedImage = [[UIImage imageNamed:@"A_liked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _likeButton = [[VActionButton alloc] init];
    [_likeButton setImage:likeImage forState:UIControlStateNormal];
    [_likeButton setImage:likedImage forState:UIControlStateSelected];
    [_overlayContainer addSubview:_likeButton];
    _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_likeButton v_addWidthConstraint:kButtonWidth];
    _likeButtonWidth = [_likeButton v_internalWidthConstraint];
    [_likeButton v_addHeightConstraint:kButtonHeight];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_overlayContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:12.0f]];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_captionTextView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f]];
    
    [_likeButton addTarget:self action:@selector(selectedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Comments button
    UIImage *commentImage = [[UIImage imageNamed:@"A_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _commentButton = [[VActionButton alloc] init];
    [_commentButton setImage:commentImage forState:UIControlStateNormal];
    [_overlayContainer addSubview:_commentButton];
    _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_commentButton v_addWidthConstraint:kButtonWidth];
    [_commentButton v_addHeightConstraint:kButtonHeight];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_commentButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_likeButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0f]];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_commentButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_captionTextView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f]];
    
    [_commentButton addTarget:self action:@selector(selectedCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self layoutIfNeeded];
}

+ (VCellSizeCollection *)cellLayoutCollection
{
    static VCellSizeCollection *collection;
    if ( collection == nil )
    {
        collection = [[VCellSizeCollection alloc] init];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             return CGSizeMake( 0.0f, size.width / [sequence previewAssetAspectRatio] );
         }];
        [collection addComponentWithConstantSize:CGSizeMake( 0.0, -kButtonHeight )];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
             NSDictionary *attributes = [self sequenceDescriptionAttributesWithDependencyManager:dependencyManager];
             CGFloat textHeight = 0.0f;
             if ( sequence.name.length > 0 )
             {
                 textHeight = VCEIL( [sequence.name frameSizeForWidth:size.width andAttributes:attributes].height );
                 textHeight = MIN( textHeight, kCountsTextViewMaxHeight);
             };
             return CGSizeMake( 0.0f, textHeight );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
             NSDictionary *attributes = [[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager];
             
             // FIXME: The use of "V" is just to get a good size for *something* in this text field since
             // we can't know what the actual text for the label is in a static method
             return CGSizeMake( 0.0f, MAX( kCountsTextViewMaxHeight, [@"V" frameSizeForWidth:size.width andAttributes:attributes].height ) );
         }];
    }
    return collection;
}

#pragma mark - Property Accessors

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateBottomGradientLocations];
}

- (void)updateBottomGradientLocations
{
    CGFloat gradientBandThickness = 60.0f;
    CGFloat startPointY = CGRectGetMinY(self.captionTextView.frame);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    CGFloat start = (startPointY - gradientBandThickness) / boundsHeight;
    CGFloat end = startPointY / boundsHeight;
    [self.bottomGradient setLocations:@[ @(start), @(end) ]];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.header.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    
    __weak typeof(self) welf = self;
    self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
    [self.expressionsObserver startObservingWithSequence:sequence onUpdate:^
    {
        welf.likeButton.selected = sequence.isLikedByMainUser.boolValue;
        [welf updateCountsTextViewForSequence:sequence];
    }];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.dependencyManager setHighlighted:highlighted onHost:self];
}

- (void)selectedLikeButton:(UIButton *)likeButton
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willLikeSequence:withView:completion:)
                                                                  withSender:self];
    
    NSAssert( responder != nil , @"We need an object in the responder chain for liking.");
    likeButton.enabled = NO;
    [responder willLikeSequence:self.sequence withView:likeButton completion:^(BOOL success)
     {
         likeButton.enabled = YES;
     }];
}

- (void)selectedCommentButton:(UIButton *)commentButton
{
    [self commentsTextSelected];
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

#pragma mark - Internal Methods

- (void)updateCountsTextViewForSequence:(VSequence *)sequence
{
    if ( !sequence.permissions.canComment )
    {
        self.commentButton.hidden = YES;
        self.countsTextView.hideComments = !sequence.permissions.canComment;
    }
    const BOOL canLike = [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue;
    if ( !canLike )
    {
        self.likeButton.hidden = YES;
        self.likeButtonWidth.constant = 0.0;
        self.countsTextView.hideLikes = !canLike;
    }
    else
    {
        self.likeButton.hidden = NO;
        self.likeButtonWidth.constant = kButtonWidth;
    }
    [self.countsTextView setCommentsCount:sequence.commentCount.integerValue];
    [self.countsTextView setLikesCount:sequence.likeCount.integerValue];
}

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ([self.previewView canHandleSequence:sequence])
    {
        [self updateContentContainerHeightConstraint];
        [self.previewView setSequence:sequence];
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.contentContainerHeightConstraint = nil;
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.contentContainer addSubview:self.previewView];
    [self.contentContainer v_addPinToTopToSubview:self.previewView];
    [self.contentContainer v_addPinToLeadingTrailingToSubview:self.previewView];
    [self updateContentContainerHeightConstraint];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateContentContainerHeightConstraint
{
    if ( self.sequence == nil )
    {
        return;
    }
    
    CGFloat height = CGRectGetWidth(self.bounds) / [self.sequence previewAssetAspectRatio];
    if ( self.contentContainerHeightConstraint == nil )
    {
        CGFloat height = CGRectGetWidth(self.bounds) / [self.sequence previewAssetAspectRatio];
        self.contentContainerHeightConstraint = [self.previewView v_addHeightConstraint:height];
    }
    else
    {
        self.contentContainerHeightConstraint.constant = height;
    }
    [self setNeedsLayout];
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    if ( sequence.name.length == 0 || self.dependencyManager == nil )
    {
        self.captionHeight.constant = 0.0;
    }
    else
    {
        self.captionHeight.constant = kCountsTextViewMaxHeight;
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                              attributes:[VTileOverlayCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
    }
}

#pragma mark - Text Attributes

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    attributes[ NSFontAttributeName ] = [[dependencyManager fontForKey:VDependencyManagerHeading2FontKey] fontWithSize:19];
    
    paragraphStyle.maximumLineHeight = 25;
    paragraphStyle.minimumLineHeight = 25;
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowBlurRadius:4.0f];
    [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:kShadowAlpha]];
    [shadow setShadowOffset:CGSizeMake(0, 0)];
    attributes[NSShadowAttributeName] = shadow;
    
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    
    return [NSDictionary dictionaryWithDictionary:attributes];
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

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.loadingBackgroundContainer;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    if ([self.header respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.header setDependencyManager:dependencyManager];
    }
    
    self.commentButton.unselectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.commentButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.likeButton.unselectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.captionTextView.dependencyManager = dependencyManager;
    
    [self.countsTextView setTextHighlightAttributes:[[self class] sequenceCountsActiveAttributesWithDependencyManager:dependencyManager]];
    [self.countsTextView setTextAttributes:[[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager]];
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
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    return @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
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
        identifier = [VSequencePreviewView reuseIdentifierForSequence:(VSequence *)streamItem
                                                       baseIdentifier:identifier
                                                    dependencyManager:dependencyManager];
    }
    return identifier;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(hashTag:tappedFromSequence:fromView:)
                                                                  withSender:self];
    NSAssert( responder != nil, @"We need an object in the responder chain for hash tag selection.!" );
    [responder hashTag:value tappedFromSequence:self.sequence fromView:self];
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

- (VFocusType)focusType
{
    if ([self.previewView conformsToProtocol:@protocol(VFocusable)])
    {
        return [(id <VFocusable>)self.previewView focusType];
    }
    return _focusType;
}

- (CGRect)contentArea
{
    return self.contentContainer.frame;
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

@end
