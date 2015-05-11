//
//  VInsetStreamCollectionCell.m
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetStreamCollectionCell.h"

// Libraries
#import <FBKVOController.h>
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

// Stream Support
#import "VSequence+Fetcher.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VSequencePreviewView.h"
#import "UIView+AutoLayout.h"
#import "NSString+VParseHelp.h"
#import "VInsetActionView.h"
#import "VHashTagTextView.h"
#import "VStreamHeaderTimeSince.h"

static const CGFloat kAspectRatio = 0.94375f; // 320/302
static const CGFloat kInsetCellHeaderHeight = 50.0f;
static const CGFloat kInsetCellActionViewHeight = 41.0f;
static const UIEdgeInsets kTextMargins = {10.0f, 10.0f, 10.0f, 10.0f}; // The margins that should be around BOTH the caption and label (treating them together as a single unit)
static const CGFloat kTextSeparatorHeight = 6.0f; // This represents the space between the label and textView. It's slightly smaller than the those separating the label and textview from their respective bottom and top to neighboring views so that the centers of words are better aligned

@interface VInsetStreamCollectionCell () <CCHLinkTextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VStreamHeaderTimeSince *header;
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) VSequencePreviewView *previewView;
@property (nonatomic, strong) VHashTagTextView *captionTextView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) VInsetActionView *actionView;

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
    [self.contentView addSubview:_previewContainer];
    [self.contentView v_addPinToLeadingTrailingToSubview:_previewContainer];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_header][_previewContainer]"
                                                                             options:kNilOptions
                                                                             metrics:0
                                                                               views:NSDictionaryOfVariableBindings(_header, _previewContainer)]];
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
    _captionTextView.linkDelegate = self;
    _captionTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_captionTextView];
    [self.contentView v_addPinToLeadingTrailingToSubview:_captionTextView
                                                 leading:kTextMargins.left
                                                trailing:kTextMargins.right];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_previewContainer
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_captionTextView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:-kTextMargins.top]];
    // Comments Label
    _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_commentsLabel];
    [self.contentView v_addPinToLeadingTrailingToSubview:_commentsLabel
                                                 leading:kTextMargins.left
                                                trailing:kTextMargins.right];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_captionTextView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_commentsLabel
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0f
                                                                  constant:-kTextSeparatorHeight]];
    
    // Action View
    _actionView = [[VInsetActionView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_actionView];
    [self.contentView v_addPinToLeadingTrailingToSubview:_actionView];
    [self.contentView v_addPinToBottomToSubview:_actionView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_commentsLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_actionView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
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
    self.commentsLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.commentsLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updatePreviewViewForSequence:sequence];
    self.header.sequence = sequence;
    self.actionView.sequence = sequence;
    [self updateCaptionViewForSequence:sequence];
    [self reloadCommentsCountForSequence:sequence];
}

#pragma mark - Internal Methods

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ([self.previewView class] == [VSequencePreviewView classTypeForSequence:sequence])
    {
        [self.previewView setSequence:sequence];
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.previewContainer addSubview:self.previewView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    if (sequence.name == nil || self.dependencyManager == nil)
    {
        return;
    }
    
    self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                          attributes:[VInsetStreamCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
}

- (void)reloadCommentsCountForSequence:(VSequence *)sequence
{
    NSNumber *commentCount = [sequence commentCount];
    NSString *commentsString = nil;
    NSInteger cCount = [commentCount integerValue];
    if (cCount == 0)
    {
        commentsString = NSLocalizedString(@"LeaveAComment", @"");
    }
    else
    {
        commentsString = [NSString stringWithFormat:@"%@ %@", [commentCount stringValue], [commentCount integerValue] == 1 ? NSLocalizedString(@"Comment", @"") : NSLocalizedString(@"Comments", @"")];
    }
    [self.commentsLabel setText:commentsString];
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

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
{
    NSMutableString *mutableBaseIdentifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier mutableCopy];
    [mutableBaseIdentifier appendString:NSStringFromClass(self)];
    [mutableBaseIdentifier appendFormat:@".%@.", NSStringFromClass([VSequencePreviewView classTypeForSequence:sequence])];
    NSString *reuseIdentifierForActionView = [VInsetActionView reuseIdentifierForSequence:sequence
                                                                           baseIdentifier:[NSString stringWithString:mutableBaseIdentifier]];
    return reuseIdentifierForActionView;
}

#pragma mark - NSAttributedString Attributes

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{
             NSForegroundColorAttributeName: [dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
             NSFontAttributeName: [dependencyManager fontForKey:VDependencyManagerParagraphFontKey]
             };
}

+ (NSDictionary *)sequenceCommentCountAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{ NSFontAttributeName : [dependencyManager fontForKey:VDependencyManagerLabel3FontKey] };
}

#pragma mark - Sizing

#warning Sizing is broken
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];
    
    CGFloat width = actual.width - kTextMargins.left - kTextMargins.right;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        // Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
        actual.height += textSize.height + kTextSeparatorHeight + kTextMargins.top + kTextMargins.bottom;
    }
    
    CGSize textSize = [[sequence.commentCount stringValue] frameSizeForWidth:width
                                                               andAttributes:[self sequenceCommentCountAttributesWithDependencyManager:dependencyManager]];
    actual.height += textSize.height;
    
    return actual;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    width *= kAspectRatio;
    // Use width to ensure 1:1 aspect ratio of previewView
    CGFloat height = kInsetCellHeaderHeight + width + kInsetCellActionViewHeight;
    return CGSizeMake(width, height);
}

@end
