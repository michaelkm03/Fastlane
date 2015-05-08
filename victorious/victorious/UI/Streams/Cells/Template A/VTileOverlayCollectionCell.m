//
//  VTileOverlayCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTileOverlayCollectionCell.h"

// Stream Support
#import "VSequence+Fetcher.h"
#import "VSequenceActionsDelegate.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VSequencePreviewView.h"
#import "UIView+AutoLayout.h"
#import "VHashTagTextView.h"
#import "VPassthroughContainerView.h"
#import "VStreamHeaderComment.h"
#import "VLinearGradientView.h"
#import "VHashTagTextView.h"
#import <CCHLinkTextViewDelegate.h>

static const CGFloat kHeaderHeight = 74.0f;
static const CGFloat kGradientAlpha = 0.3f;
static const UIEdgeInsets kTextInsets = {0, 20.0f, 20.0f, 20.0f};
static const CGFloat kPollCellHeightRatio = 0.66875f; //from spec, 214 height for 320 width
static const CGFloat minCaptionHeight = 25.0f;
static const CGFloat maxCaptionHeight = 80.0f;

@interface VTileOverlayCollectionCell () <CCHLinkTextViewDelegate>

@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIView *loadingBackgroundContainer;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) VPassthroughContainerView *overlayContainer;
@property (nonatomic, strong) VLinearGradientView *topGradient;
@property (nonatomic, strong) VLinearGradientView *bottomGradient;
@property (nonatomic, strong) VStreamHeaderComment *header;
@property (nonatomic, strong) VHashTagTextView *captionTextView;

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
    _loadingBackgroundContainer = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_loadingBackgroundContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_loadingBackgroundContainer];
    
    _contentContainer = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_contentContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_contentContainer];
    
    _overlayContainer = [[VPassthroughContainerView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_overlayContainer];
    [self.contentView v_addFitToParentConstraintsToSubview:_overlayContainer];
    
    _topGradient = [[VLinearGradientView alloc] initWithFrame:CGRectZero];
    _topGradient.userInteractionEnabled = NO;
    [_overlayContainer addSubview:_topGradient];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_topGradient];
    [_overlayContainer v_addPinToTopToSubview:_topGradient];
    [_topGradient v_addHeightConstraint:kHeaderHeight];
    UIColor *gradientBlack = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_topGradient setColors:@[gradientBlack, [UIColor clearColor]]];
    
    _bottomGradient = [[VLinearGradientView alloc] initWithFrame:CGRectZero];
    _bottomGradient.userInteractionEnabled = NO;
    [_overlayContainer addSubview:_bottomGradient];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_bottomGradient];
    [_overlayContainer v_addPinToBottomToSubview:_bottomGradient];
    [_bottomGradient setColors:@[[UIColor clearColor], gradientBlack]];
    
    _header = [[VStreamHeaderComment alloc] initWithFrame:CGRectZero];
    [_overlayContainer addSubview:_header];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_header];
    [_overlayContainer v_addPinToTopToSubview:_header];
    [_header v_addHeightConstraint:kHeaderHeight];
    _header.sequence = self.sequence;
    if ([_header respondsToSelector:@selector(setDependencyManager:)])
    {
        [_header setDependencyManager:self.dependencyManager];
    }
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
    [_overlayContainer v_addPinToBottomToSubview:_captionTextView];
    [_overlayContainer v_addPinToLeadingTrailingToSubview:_captionTextView];
    [_captionTextView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0f
                                                                  constant:minCaptionHeight]];
    [_captionTextView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0f
                                                                  constant:maxCaptionHeight]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_bottomGradient
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.header.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    [self updateOverlayGradientsForSequence:sequence];
}

#pragma mark - Internal Methods

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
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
    [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:kGradientAlpha]];
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
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
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

@end
