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
#import "VStreamHeaderTimeSince.h"
#import "VCompatibility.h"
#import "VStreamCollectionViewController.h"
#import "VSequenceCountsTextView.h"
#import "VSequenceExpressionsObserver.h"

static const CGFloat kAspectRatio                   = 0.94375f; //< 320 ÷ 302
static const CGFloat kInsetCellHeaderHeight         = 50.0f;
static const CGFloat kInsetCellActionViewHeight     = 41.0f;
static const CGFloat kCountsTextViewHeight          = 20.0f;
static const CGFloat kMaxCaptionHeight              = 80.0f;
static const UIEdgeInsets kTextMargins              = { 10.0f, 10.0f, 0.0f, 10.0f };

@interface VInsetStreamCollectionCell () <CCHLinkTextViewDelegate, VSequenceCountsTextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VStreamHeaderTimeSince *header;
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) UIView *dimmingContainer;
@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VHashTagTextView *captionTextView;
@property (nonatomic, strong) VSequenceCountsTextView *countsTextView;
@property (nonatomic, strong) VInsetActionView *actionView;
@property (nonatomic, strong) NSLayoutConstraint *previewViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *countsVerticalSpacing;
@property (nonatomic, strong) VSequenceExpressionsObserver *expressionsObserver;

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
    // Header at the top, left to right and kInsetCellHeaderHeight
    _header = [[VStreamHeaderTimeSince alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_header];
    [self.contentView v_addPinToLeadingTrailingToSubview:_header];
    [self.contentView v_addPinToTopToSubview:_header];
    [_header v_addHeightConstraint:kInsetCellHeaderHeight];
    
    // Next preview container, left to right, 1:1 aspect ratio
    _previewContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _previewContainer.clipsToBounds = YES;
    [self.contentView addSubview:_previewContainer];
    [self.contentView v_addPinToLeadingTrailingToSubview:_previewContainer];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_header][_previewContainer]"
                                                                             options:kNilOptions
                                                                             metrics:0
                                                                               views:NSDictionaryOfVariableBindings(_header, _previewContainer)]];
    NSLayoutConstraint *heightToWidth = [NSLayoutConstraint constraintWithItem:_previewContainer
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_previewContainer
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0f
                                                                      constant:0.0f];
    [self.contentView addConstraint:heightToWidth];
    _previewViewHeightConstraint = heightToWidth;
    
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
    _captionTextView.textContainerInset = UIEdgeInsetsZero;
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

    
    // Comments and likes count
    _countsTextView = [[VSequenceCountsTextView alloc] init];
    _countsTextView.contentInset = UIEdgeInsetsMake( 0, -4, 0, 0 );
    _countsTextView.textSelectionDelegate = self;
    [self.contentView addSubview:_countsTextView];
    _countsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_countsTextView v_addHeightConstraint:kCountsTextViewHeight];
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
    
    self.countsTextView.dependencyManager = dependencyManager;
    
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
    
    __weak typeof(self) welf = self;
    self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
    [self.expressionsObserver startObservingWithSequence:sequence onUpdate:^
     {
         welf.actionView.likeButton.selected = sequence.isLikedByMainUser.boolValue;
         [welf.countsTextView setCommentsCount:sequence.commentCount.integerValue];
         [welf.countsTextView setLikesCount:sequence.likeCount.integerValue];
     }];
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
        self.countsVerticalSpacing.constant = -spacing;
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
{
    NSString *identifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier copy];
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        identifier = [VSequencePreviewView reuseIdentifierForStreamItem:streamItem
                                                         baseIdentifier:identifier];
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

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    // Size the inset cell from top to bottom
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat fullWidth = VFLOOR(width * kAspectRatio);
    
    // Use width to ensure 1:1 aspect ratio of previewView
    CGSize actualSize = CGSizeMake(fullWidth, 0.0f);
    
    // Add header
    actualSize.height = actualSize.height + kInsetCellHeaderHeight;
    
    // Text size
    actualSize = [self sizeByAddingTextAreaSizeToSize:actualSize
                                             sequence:sequence
                                    dependencyManager:dependencyManager];
    
    // Action View
    actualSize.height = actualSize.height + kInsetCellActionViewHeight;
    
    // Add 1:1 preview view
    actualSize.height = actualSize.height + actualSize.width * (1 / [sequence previewAssetAspectRatio]);
    
    return actualSize;
}

+ (CGSize)sizeByAddingTextAreaSizeToSize:(CGSize)initialSize
                                sequence:(VSequence *)sequence
                       dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize sizeWithText = initialSize;
    
    // Top Margins
    sizeWithText.height = sizeWithText.height + kTextMargins.top;
    
    NSValue *textSizeValue = [[self textSizeCache] objectForKey:sequence.name];
    if (textSizeValue != nil)
    {
        return [textSizeValue CGSizeValue];
    }
    
    // Comment size
    CGFloat textAreaWidth = sizeWithText.width - kTextMargins.left - kTextMargins.right;
    if ( sequence.name != nil && sequence.name.length > 0 )
    {
        // Caption view size
        CGSize captionSize = [sequence.name frameSizeForWidth:textAreaWidth
                                                andAttributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
        sizeWithText.height += VCEIL(captionSize.height);
    }
    
    sizeWithText.height += kCountsTextViewHeight;
    
    // Bottom Margins
    sizeWithText.height += kTextMargins.bottom;
    [[self textSizeCache] setObject:[NSValue valueWithCGSize:sizeWithText] forKey:sequence.name];
    return sizeWithText;
}

+ (NSCache *)textSizeCache
{
    static NSCache *textSizeCache;
    if (textSizeCache == nil)
    {
        textSizeCache = [[NSCache alloc] init];
    }
    return textSizeCache;
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
    return self.previewView.frame;
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
