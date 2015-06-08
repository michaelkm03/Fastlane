//
//  VSleekStreamCollectionCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCollectionCell.h"

// Libraries
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

// Stream Support
#import "VSequence+Fetcher.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VSequencePreviewView.h"
#import "UIView+AutoLayout.h"
#import "NSString+VParseHelp.h"
#import "VSleekActionView.h"
#import "VHashTagTextView.h"
#import "VStreamHeaderTimeSince.h"
#import "VCompatibility.h"

static const CGFloat kSleekCellHeaderHeight = 50.0f;
static const CGFloat kSleekCellActionViewHeight = 41.0f;
static const CGFloat kPreviewToActionViewSpacing = 8.0f;
static const CGFloat kActionViewBottomSpacing = 28.0f;
static const CGFloat kSleekCellActionViewBottomConstraintHeight = 34.0f; //This represents the space between the bottom of the cell and the actionView
static const CGFloat kSleekCellActionViewTopConstraintHeight = 8.0f; //This represents the space between the bottom of the content and the top of the actionView
static const UIEdgeInsets kCaptionMargins = { 0.0f, 45.0f, 5.0f, 10.0f };
//Use this constant adjust the spacing between the caption and comment
const CGFloat kSleekCellTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VSleekStreamCollectionCell () <VBackgroundContainer, CCHLinkTextViewDelegate>

@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet UIView *previewContainer;
@property (nonatomic, weak) IBOutlet UIView *loadingBackgroundContainer;
@property (nonatomic, weak) IBOutlet VSleekActionView *sleekActionView;
@property (nonatomic, weak) IBOutlet VStreamHeaderTimeSince *headerView;
@property (nonatomic, weak) IBOutlet VHashTagTextView *captionTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceCaptionToPreview;
@property (nonatomic, weak ) IBOutlet NSLayoutConstraint *previewContainerHeightConstraint;

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VSleekStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.previewContainer.clipsToBounds = YES;
    self.captionTextView.textContainerInset = UIEdgeInsetsZero;
    self.captionTextView.linkDelegate = self;
    [self setupDimmingView];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if (_dependencyManager == dependencyManager)
    {
        return;
    }
    _dependencyManager = dependencyManager;

    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    if ([self.sleekActionView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.sleekActionView setDependencyManager:dependencyManager];
    }
    if ([self.headerView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.headerView setDependencyManager:dependencyManager];
    }
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.headerView.sequence = sequence;
    self.sleekActionView.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    [self.previewContainer removeConstraint:self.previewContainerHeightConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    // Determine if this cell shows its highlighted state
    BOOL showsHighlight = [[self.dependencyManager numberForKey:kStreamCellShowsHighlightedStateKey] boolValue];
    if (showsHighlight)
    {
        [UIView animateWithDuration:0.1 animations:^
         {
             self.dimmingView.alpha = highlighted ? 0.6f : 0;
         }];
    }
}

#pragma mark - Internal Methods

- (void)setupDimmingView
{
    self.dimmingView = [UIView new];
    self.dimmingView.backgroundColor = [UIColor blackColor];
    self.dimmingView.alpha = 0;
    self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewContainer addSubview:self.dimmingView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.dimmingView];
}

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
    [self.previewContainer addConstraint:heightToWidth];
    self.previewContainerHeightConstraint = heightToWidth;
    
    [super updateConstraints];
}

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ([self.previewView canHandleSequence:sequence])
    {
        [self.previewView setSequence:sequence];
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    if (sequence.name == nil || self.dependencyManager == nil || sequence.name.length == 0)
    {
        self.captionTextView.attributedText = nil;
        self.bottomSpaceCaptionToPreview.constant = 0.0f;
        [self.captionTextView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    else
    {
        [self.captionTextView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        self.bottomSpaceCaptionToPreview.constant = kCaptionMargins.bottom;
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                              attributes:[VSleekStreamCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.loadingBackgroundContainer;
}

- (UIView *)backgroundContainerView
{
    return self.contentView;
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
{
    NSString *identifier = baseIdentifier == nil ? [[NSString alloc] init] : baseIdentifier;
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        identifier = [VSequencePreviewView reuseIdentifierForSequence:(VSequence *)streamItem
                                                       baseIdentifier:identifier];
    }
    
    return [VSleekActionView reuseIdentifierForStreamItem:streamItem
                                           baseIdentifier:identifier];
}

#pragma mark - Class Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width +
                     kSleekCellHeaderHeight +
                     kSleekCellActionViewHeight +
                     kSleekCellActionViewBottomConstraintHeight +
                     kSleekCellActionViewTopConstraintHeight;
    return CGSizeMake(width, height);
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if ( dependencyManager != nil )
    {
        attributes[ NSFontAttributeName ] = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
    attributes[ NSParagraphStyleAttributeName ] = [[NSMutableParagraphStyle alloc] init];
    return [NSDictionary dictionaryWithDictionary:attributes];
}

#pragma mark - Sizing

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    // Size the inset cell from top to bottom
    // Use width to ensure 1:1 aspect ratio of previewView
    CGSize actualSize = CGSizeMake(CGRectGetWidth(bounds), 0.0f);

    // Add header
    actualSize.height = actualSize.height + kSleekCellHeaderHeight;

    // Text size
    actualSize = [self sizeByAddingTextAreaSizeToSize:actualSize
                                             sequence:sequence
                                    dependencyManager:dependencyManager];
    
    // Add 1:1 preview view
    actualSize.height = actualSize.height + actualSize.width * (1 / [sequence previewAssetAspectRatio]);
    
    // Action View
    actualSize.height = actualSize.height + kPreviewToActionViewSpacing;
    actualSize.height = actualSize.height + kSleekCellActionViewHeight;
    actualSize.height = actualSize.height + kActionViewBottomSpacing;
    
    return actualSize;
}

+ (CGSize)sizeByAddingTextAreaSizeToSize:(CGSize)initialSize
                                sequence:(VSequence *)sequence
                       dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize sizeWithText = initialSize;
    
    NSValue *textSizeValue = [[self textSizeCache] objectForKey:sequence.name];
    if (textSizeValue != nil)
    {
        return [textSizeValue CGSizeValue];
    }
    
    CGFloat captionWidth = initialSize.width - kCaptionMargins.left - kCaptionMargins.right;
    if (sequence.name.length > 0)
    {
        // Caption view size
        static NSDictionary *sharedAttributes = nil;
        if (sharedAttributes == nil)
        {
            sharedAttributes = [self sequenceDescriptionAttributesWithDependencyManager:dependencyManager];
        }
        
        CGSize size = [sequence.name frameSizeForWidth:captionWidth
                                         andAttributes:sharedAttributes];
        sizeWithText.height = sizeWithText.height + size.height + kCaptionMargins.top + kCaptionMargins.bottom;
    }
    [[self textSizeCache] setObject:[NSValue valueWithCGSize:sizeWithText]
                             forKey:sequence.name];
    return sizeWithText;
}

+ (NSCache *)textSizeCache
{
    static NSCache *textCache;
    if (textCache == nil)
    {
        textCache = [[NSCache alloc] init];
    }
    return textCache;
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
    return self.previewContainer.frame;
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

#pragma mark - VStreamCellTracking

- (VSequence *)sequenceToTrack
{
    return self.sequence;
}

@end
