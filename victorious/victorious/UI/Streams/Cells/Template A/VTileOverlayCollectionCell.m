//
//  VTileOverlayCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CCHLinkTextViewDelegate.h>

#import "UIView+AutoLayout.h"
#import "VTileOverlayCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionsDelegate.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VSequencePreviewView.h"
#import "VHashTagTextView.h"
#import "VPassthroughContainerView.h"
#import "VStreamHeaderComment.h"
#import "VLinearGradientView.h"
#import "VHashTagTextView.h"
#import "VSequenceExpressionsObserver.h"
#import "VActionButton.h"
#import "VSequenceCountsTextView.h"

static const UIEdgeInsets kTextInsets       = { 0, 20.0f, 20.0f, 20.0f };
static const CGFloat kHeaderHeight          = 74.0f;
static const CGFloat kGradientAlpha         = 0.3f;
static const CGFloat kShadowAlpha           = 0.5f;
static const CGFloat kPollCellHeightRatio   = 0.66875f; //< from spec, 214 height for 320 width
static const CGFloat kMaxCaptionHeight      = 80.0f;
static const CGFloat kButtonWidth           = 44.0f;
static const CGFloat kButtonHeight          = 44.0f;

@interface VTileOverlayCollectionCell () <CCHLinkTextViewDelegate, VSequenceCountsTextViewDelegate>

@property (nonatomic, strong) UIView *loadingBackgroundContainer;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *dimmingContainer;
@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VPassthroughContainerView *overlayContainer;
@property (nonatomic, strong) VLinearGradientView *topGradient;
@property (nonatomic, strong) VLinearGradientView *bottomGradient;
@property (nonatomic, strong) VStreamHeaderComment *header;
@property (nonatomic, strong) VHashTagTextView *captionTextView;
@property (nonatomic, strong) VSequenceExpressionsObserver *expressionsObserver;

@property (nonatomic, strong) VActionButton *likeButton;
@property (nonatomic, strong) VActionButton *commentButton;

@property (nonatomic, strong) VSequenceCountsTextView *countsTextView;

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
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_bottomGradient];
    [_overlayContainer v_addPinToBottomToSubview:_bottomGradient];
    [_bottomGradient v_addHeightConstraint:100.0f];
    [_bottomGradient setColors:@[ [UIColor clearColor], [UIColor blackColor] ]];
    
    // Add the header
    _header = [[VStreamHeaderComment alloc] initWithFrame:CGRectZero];
    [_overlayContainer addSubview:_header];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_header];
    [_overlayContainer v_addPinToTopToSubview:_header];
    [_header v_addHeightConstraint:kHeaderHeight];
    _header.sequence = self.sequence;
    
    // Comments and likes count
    _countsTextView = [[VSequenceCountsTextView alloc] init];
    _countsTextView.textSelectionDelegate = self;
    _countsTextView.textContainerInset = (UIEdgeInsets){ 0, 16.0f, 0.0f, 10.0f };
    [_countsTextView sizeToFit];
    _countsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_overlayContainer addSubview:_countsTextView];
    [_countsTextView v_addHeightConstraint:20.0f];
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
    _captionTextView.backgroundColor = [UIColor clearColor];
    [_overlayContainer addSubview:_captionTextView];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_captionTextView];
    [_captionTextView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kMaxCaptionHeight]];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_countsTextView attribute:NSLayoutAttributeTop multiplier:1.0f constant:15.0f]];
    
    // Like button
    
    UIImage *likeInactiveImage = [[UIImage imageNamed:@"A_like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *likeActiveImage = [[UIImage imageNamed:@"A_liked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _likeButton = [VActionButton actionButtonWithImage:likeInactiveImage activeImage:likeActiveImage];
    [_overlayContainer addSubview:_likeButton];
    _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_likeButton v_addWidthConstraint:kButtonWidth];
    [_likeButton v_addHeightConstraint:kButtonHeight];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_overlayContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:12.0f]];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_captionTextView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f]];
    
    [_likeButton addTarget:self action:@selector(selectedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Comments button
    UIImage *commentImage = [[UIImage imageNamed:@"A_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _commentButton = [VActionButton actionButtonWithImage:commentImage activeImage:nil];
    [_overlayContainer addSubview:_commentButton];
    _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_commentButton v_addWidthConstraint:kButtonWidth];
    [_commentButton v_addHeightConstraint:kButtonHeight];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_commentButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_likeButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0f]];
    [_overlayContainer addConstraint:[NSLayoutConstraint constraintWithItem:_commentButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_captionTextView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f]];
    
    [_commentButton addTarget:self action:@selector(selectedCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self layoutIfNeeded];
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.header.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    [self updateOverlayGradientsForSequence:sequence];
    
    __weak typeof(self) welf = self;
    self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
    [self.expressionsObserver startObservingWithSequence:sequence onUpdate:^
    {
        [welf.likeButton setActive:sequence.isLikedByMainUser.boolValue];
        [welf.countsTextView setCommentsCount:sequence.commentCount.integerValue];
        [welf.countsTextView setLikesCount:sequence.likeCount.integerValue];
    }];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.dependencyManager setHighlighted:highlighted onHost:self];
}

- (void)selectedLikeButton:(UIButton *)likeButton
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willLikeSequence:completion:)
                                                                  withSender:self];
    
    NSAssert( responder != nil , @"We need an object in the responder chain for liking.");
    likeButton.enabled = NO;
    [responder willLikeSequence:self.sequence completion:^(BOOL success)
     {
         likeButton.enabled = YES;
     }];
}

- (void)selectedCommentButton:(UIButton *)commentButton
{
    [self likersTextSelected];
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

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ([self.previewView canHandleSequence:sequence])
    {
        [self.previewView setSequence:sequence];
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.contentContainer addSubview:self.previewView];
    [self.contentContainer v_addFitToParentConstraintsToSubview:self.previewView];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateOverlayGradientsForSequence:(VSequence *)sequence
{
    BOOL bottomGradientHidden = NO;
    if ([sequence isText])
    {
        bottomGradientHidden = YES;
    }
    if ([sequence.nameEmbeddedInContent boolValue])
    {
        bottomGradientHidden = YES;
    }
    if (sequence.name.length == 0)
    {
        bottomGradientHidden = YES;
    }
    self.bottomGradient.hidden = bottomGradientHidden;
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    if (sequence.name == nil || self.dependencyManager == nil)
    {
        self.captionTextView.hidden = YES;
        return;
    }
    self.captionTextView.hidden = NO;
    self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                          attributes:[VTileOverlayCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
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

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    if ([sequence isPoll])
    {
        CGFloat width = CGRectGetWidth(bounds);
        return CGSizeMake(width, width * kPollCellHeightRatio);
    }
        
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds) * (1 / [sequence previewAssetAspectRatio]));
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
    
    self.commentButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.commentButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.likeButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.countsTextView.dependencyManager = dependencyManager;
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
{
    NSString *identifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier copy];
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        identifier = [VSequencePreviewView reuseIdentifierForSequence:(VSequence *)streamItem
                                                       baseIdentifier:identifier];
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

#pragma mark - VStreamCellFocus

- (void)setHasFocus:(BOOL)hasFocus
{
    if ([self.previewView conformsToProtocol:@protocol(VStreamCellFocus)])
    {
        [(id <VStreamCellFocus>)self.previewView setHasFocus:hasFocus];
    }
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
