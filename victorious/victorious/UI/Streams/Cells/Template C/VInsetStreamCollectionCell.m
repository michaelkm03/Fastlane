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
#import "VCompatibility.h"

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

@property (nonatomic, strong) NSArray *captionConstraints;
@property (nonatomic, strong) NSArray *noCaptionConstraints;

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
    NSLayoutConstraint *previewContainerBottomToCaptionTop = [NSLayoutConstraint constraintWithItem:_previewContainer
                                                                                          attribute:NSLayoutAttributeBottom
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:_captionTextView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1.0f
                                                                                           constant:-kTextMargins.top];
    // Comments Label
    _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_commentsLabel];
    [self.contentView v_addPinToLeadingTrailingToSubview:_commentsLabel
                                                 leading:kTextMargins.left
                                                trailing:kTextMargins.right];
    NSLayoutConstraint *captionTextViewBottomToCommentsLabelTop = [NSLayoutConstraint constraintWithItem:_captionTextView
                                                                                               attribute:NSLayoutAttributeBottom
                                                                                               relatedBy:NSLayoutRelationEqual
                                                                                                  toItem:_commentsLabel
                                                                                               attribute:NSLayoutAttributeTop
                                                                                              multiplier:1.0f
                                                                                                constant:-kTextSeparatorHeight];
    
    _actionView = [[VInsetActionView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_actionView];
    [self.contentView v_addPinToLeadingTrailingToSubview:_actionView];
    [self.contentView v_addPinToBottomToSubview:_actionView];
    [_actionView v_addHeightConstraint:kInsetCellActionViewHeight];
    NSLayoutConstraint *commentsLabelBottomToActionViewTop = [NSLayoutConstraint constraintWithItem:_commentsLabel
                                                                                          attribute:NSLayoutAttributeBottom
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:_actionView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1.0f
                                                                                           constant:-kTextMargins.bottom];
    
    NSLayoutConstraint *previewViewBottomToCommentsLabelTop = [NSLayoutConstraint constraintWithItem:_previewContainer
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:_commentsLabel
                                                                                           attribute:NSLayoutAttributeTop
                                                                                          multiplier:1.0f
                                                                                            constant:-kTextMargins.top];
    
    self.captionConstraints = @[previewContainerBottomToCaptionTop, captionTextViewBottomToCommentsLabelTop, commentsLabelBottomToActionViewTop];
    self.noCaptionConstraints = @[previewViewBottomToCommentsLabelTop, commentsLabelBottomToActionViewTop];
    [self.contentView addConstraints:self.captionConstraints];
    [self.contentView addConstraints:self.noCaptionConstraints];
    [NSLayoutConstraint deactivateConstraints:self.captionConstraints];
    [NSLayoutConstraint deactivateConstraints:self.noCaptionConstraints];
}

#pragma mark - UIView

- (void)updateConstraints
{
    if (self.sequence.name.length > 0)
    {
        [NSLayoutConstraint deactivateConstraints:self.noCaptionConstraints];
        [NSLayoutConstraint activateConstraints:self.captionConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.captionConstraints];
        [NSLayoutConstraint activateConstraints:self.noCaptionConstraints];
    }
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
    [self setNeedsUpdateConstraints];
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
        self.captionTextView.attributedText = nil;
        self.captionTextView.hidden = YES;
        return;
    }
    self.captionTextView.hidden = NO;
    self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                          attributes:[VInsetStreamCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
}

- (void)reloadCommentsCountForSequence:(VSequence *)sequence
{
    NSAttributedString *commentText = [[self class] attributedCommentTextForSequence:sequence andDependencyManager:self.dependencyManager];
    [self.commentsLabel setAttributedText:commentText];
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

+ (NSAttributedString *)attributedCommentTextForSequence:(VSequence *)sequence
                                    andDependencyManager:(VDependencyManager *)dependencyManager
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
    return [[NSAttributedString alloc] initWithString:commentsString
                                           attributes:[self sequenceCommentCountAttributesWithDependencyManager:dependencyManager]];
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{
             NSForegroundColorAttributeName: [dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
             NSFontAttributeName: [dependencyManager fontForKey:VDependencyManagerParagraphFontKey]
             };
}

+ (NSDictionary *)sequenceCommentCountAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{
             NSFontAttributeName : [dependencyManager fontForKey:VDependencyManagerLabel3FontKey],
             NSForegroundColorAttributeName: [dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
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
    
    // Add 1:1 preivew view
    actualSize.height = actualSize.height + actualSize.width;

    // Add text area sizes
    {
        // Top Margins
        actualSize.height = actualSize.height + kTextMargins.top;
        
        // Comment size
        NSAttributedString *attributedCommentText = [self attributedCommentTextForSequence:sequence
                                                                      andDependencyManager:dependencyManager];
        [self sizingCell].frame = CGRectMake(0, 0, actualSize.width, actualSize.height + actualSize.height);
        [[self sizingCell].commentsLabel setAttributedText:attributedCommentText];
        CGSize commentSize = [[self sizingCell].commentsLabel intrinsicContentSize];

        actualSize.height = actualSize.height + commentSize.height;
        if (sequence.name.length > 0)
        {
            // Inter-Text spacing
            actualSize.height = actualSize.height + kTextSeparatorHeight;
            
            // Caption view size
            NSAttributedString *attributedCaptionText = [[NSAttributedString alloc] initWithString:sequence.name
                                                                                         attributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
            [self sizingCell].captionTextView.attributedText = attributedCaptionText;
            CGSize captionSize = [[self sizingCell].captionTextView intrinsicContentSize];
            actualSize.height = actualSize.height + captionSize.height;
        }
        
        // Bottom Margins
        actualSize.height = actualSize.height + kTextMargins.bottom;
    }
    
    // Action View
    actualSize.height = actualSize.height + kInsetCellActionViewHeight;
    
    return actualSize;
}

+ (VInsetStreamCollectionCell *)sizingCell
{
    static VInsetStreamCollectionCell *sizingCell = nil;
    if (sizingCell == nil)
    {
        sizingCell = [[VInsetStreamCollectionCell alloc] initWithFrame:CGRectMake(0, 0, 600.0f, 600.0f)];
    }
    return sizingCell;
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

@end
