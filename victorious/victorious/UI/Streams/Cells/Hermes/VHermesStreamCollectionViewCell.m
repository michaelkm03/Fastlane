//
//  VHermesStreamCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHermesStreamCollectionViewCell.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackground.h"
#import "VSolidColorBackground.h"

// Views + Helpers
#import "VHashTagTextView.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>
#import "UIView+AutoLayout.h"
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "VLargeNumberFormatter.h"
#import "VSlantView.h"
#import "VHermesActionView.h"
#import "NSString+VParseHelp.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

static const CGFloat kLeadingTrailingHeaderSpace = 15.0f;
static const CGFloat kAvatarSize = 32.0f;
static const CGFloat kSpaceAvatarToLabels = 3.0f;
static const CGFloat kHeaderHeight = 62.0f;
static const CGFloat kSlantHeight = 58.0f;
static const CGFloat kMinimumCaptionContainerHeight = 15.0f;
static const CGFloat kActionBarHeight = 30.0f;
static const CGFloat kCreationInfoContainerHeight = 44.0f;
static const UIEdgeInsets kTextInsets = {10.0f, 10.0f, 15.0f, 15.0f};

@interface VHermesStreamCollectionViewCell () <CCHLinkTextViewDelegate, VCreationInfoContainerDelegate>

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *captionContainerView;
@property (nonatomic, strong) VActionBar *headerBar;
@property (nonatomic, strong) VHermesActionView *actionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) UIImageView *gradientView;
@property (nonatomic, strong) VSlantView *slantView;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;
@property (nonatomic, strong) VHashTagTextView *captionTextView;

@end

@implementation VHermesStreamCollectionViewCell

#pragma mark - VAbstractStreamCollectionCell Overrides

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
{
    NSMutableString *identifier = [NSStringFromClass([self class]) mutableCopy];
    
    if ([sequence isText])
    {
        [identifier appendString:@"Text"];
    }
    else if ([sequence isPoll])
    {
        [identifier appendString:@"Poll"];
    }
    else if ([sequence isVideo])
    {
        [identifier appendString:@"Video"];
    }
    else if ([sequence isImage])
    {
        [identifier appendString:@"Image"];
    }
    else if ([sequence isAnnouncement])
    {
        [identifier appendString:@"Announcement"];
    }
    else
    {
        VLog(@"%@, doesn't support sequence type for sequence: %@", NSStringFromClass(self), sequence);
    }
    
    return [VHermesActionView reuseIdentifierForSequence:sequence
                                          baseIdentifier:identifier];
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    if (!self.hasLayedOutViews)
    {
        [self.contentView addSubview:self.captionContainerView];

        [self.contentView v_addPinToLeadingTrailingToSubview:self.contentContainerView];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentContainerView][captionContainer]|"
                                                                                 options:kNilOptions
                                                                                 metrics:@{@"kMinimumCaptionContainerHeight": @(kMinimumCaptionContainerHeight)}
                                                                                   views:@{@"contentContainerView":self.contentContainerView,
                                                                                           @"captionContainer": self.captionContainerView}]];
        
        [self.contentView v_addPinToLeadingTrailingToSubview:self.captionContainerView];
        
        [self.contentContainerView addSubview:self.slantView];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.slantView];
        [self.contentContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerView
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentContainerView
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0f
                                                                               constant:0.0f]];
        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[slantView(kSlantHeight)]|"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"kSlantHeight": @(kSlantHeight)}
                                                                                            views:@{@"slantView":self.slantView}]];
        [self.contentContainerView addSubview:self.gradientView];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.gradientView];
        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[gradient(kHeaderHeight)]"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"kHeaderHeight":@(kHeaderHeight)}
                                                                                            views:@{@"gradient":self.gradientView}]];
        [self.contentContainerView addSubview:self.headerBar];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.headerBar];
        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerBar(kHeaderHeight)]"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"kHeaderHeight":@(kHeaderHeight)}
                                                                                            views:@{@"headerBar":self.headerBar}]];
        [self.contentView addSubview:self.actionBar];
        [self.contentView v_addPinToLeadingTrailingToSubview:self.actionBar];
        [self.actionBar v_addHeightConstraint:kActionBarHeight];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionBar
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.captionContainerView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
        self.hasLayedOutViews = YES;
    }
    
    // Do any updates if we just created the views
    [self updateCaptionViewWithSequence:self.sequence];
    [self updateProfileButtonWithSequence:self.sequence];
    [self updateCreationInfoContainerWithSequence:self.sequence];
    [self updateCommentsForSequence:self.sequence];
    
    [super layoutSubviews];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self updateCaptionViewWithSequence:sequence];
    [self updateProfileButtonWithSequence:sequence];
    [self updateCreationInfoContainerWithSequence:sequence];
    [self updateCommentsForSequence:self.sequence];
    
    self.actionBar.sequence = sequence;
    self.commentButton.hidden = ![sequence canComment];
}

- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)delegate
{
    [super setSequenceActionsDelegate:delegate];
    self.actionBar.sequenceActionsDelegate = delegate;
}

#pragma mark - Property Accessors

- (UIButton *)commentButton
{
    if (_commentButton == nil)
    {
        _commentButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _commentButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        _commentButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        [_commentButton setImage:[[UIImage imageNamed:@"StreamComments"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton v_addWidthConstraint:kCreationInfoContainerHeight];
        [_commentButton v_addHeightConstraint:kCreationInfoContainerHeight];
    }
    return _commentButton;
}

- (VHashTagTextView *)captionTextView
{
    if (_captionTextView == nil)
    {
        _captionTextView = [[VHashTagTextView alloc] initWithFrame:CGRectZero];
        _captionTextView.linkDelegate = self;
        _captionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _captionTextView.backgroundColor = [UIColor clearColor];
        _captionTextView.textContainerInset = kTextInsets;
        _captionTextView.scrollEnabled = NO;
    }
    return _captionTextView;
}

- (UIView *)contentContainerView
{
    if (_contentContainerView == nil)
    {
        _contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_contentContainerView];
        [_contentContainerView addSubview:self.previewView];
        [_contentContainerView v_addFitToParentConstraintsToSubview:self.previewView];
    }
    
    return _contentContainerView;
}

- (UIView *)captionContainerView
{
    if (_captionContainerView == nil)
    {
        _captionContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _captionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        _captionContainerView.backgroundColor = [UIColor purpleColor];
        [_captionContainerView addSubview:self.captionTextView];
        [_captionContainerView v_addFitToParentConstraintsToSubview:self.captionTextView];
    }
    return _captionContainerView;
}

- (UIImageView *)gradientView
{
    if (_gradientView == nil)
    {
        _gradientView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topGradient"]];
        _gradientView.translatesAutoresizingMaskIntoConstraints = NO;
        _gradientView.backgroundColor = [UIColor clearColor];
    }
    return _gradientView;
}

- (VSlantView *)slantView
{
    if (_slantView == nil)
    {
        _slantView = [[VSlantView alloc] initWithFrame:CGRectZero];
        _slantView.translatesAutoresizingMaskIntoConstraints = NO;
        _slantView.slantColor = [UIColor blueColor];
        _slantView.layer.masksToBounds = YES;
        _slantView.clipsToBounds = YES;
    }
    return _slantView;
}

- (VHermesActionView *)actionBar
{
    if (_actionBar == nil)
    {
        _actionBar = [[VHermesActionView alloc] init];
        _actionBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _actionBar;
}

- (VActionBar *)headerBar
{
    if (_headerBar == nil)
    {
        VActionBar *headerBar = [[VActionBar alloc] init];
        headerBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.headerBar = headerBar;
        
        VDefaultProfileButton *button = [[VDefaultProfileButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button v_addHeightConstraint:kAvatarSize];
        [button v_addWidthConstraint:kAvatarSize];
        self.profileButton = button;
        
        VCreationInfoContainer *creationContainer = [[VCreationInfoContainer alloc] initWithFrame:CGRectZero];
        creationContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        if ([creationContainer respondsToSelector:@selector(setDependencyManager:)])
        {
            [creationContainer setDependencyManager:self.dependencyManager];
        }
        [creationContainer v_addHeightConstraint:kCreationInfoContainerHeight];
        self.creationInfoContainer = creationContainer;
        self.creationInfoContainer.delegate = self;
        
        headerBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace],
                                  button,
                                  [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceAvatarToLabels],
                                  creationContainer,
                                  self.commentButton,
                                  [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace]];
    }
    
    return _headerBar;
}

- (VLargeNumberFormatter *)numberFormatter
{
    if (_numberFormatter == nil)
    {
        _numberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return _numberFormatter;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    if ([self.creationInfoContainer respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.creationInfoContainer setDependencyManager:dependencyManager];
    }
    if ([self.commentButton respondsToSelector:@selector(setDependencyManager:)])
    {
        self.commentButton.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.commentButton.tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
    VBackground *slantBackground = [dependencyManager background];
    if ([slantBackground isKindOfClass:[VSolidColorBackground class]])
    {
        self.slantView.slantColor = ((VSolidColorBackground *)slantBackground).backgroundColor;
        self.captionContainerView.backgroundColor = ((VSolidColorBackground *)slantBackground).backgroundColor;
    }
    [self.actionBar setDependencyManager:dependencyManager];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self selectedHashTag:value];
}

#pragma mark - VCreationInfoContainerDelegate

- (void)creationInfoContainer:(VCreationInfoContainer *)container
       selectedUserOnSequence:(VSequence *)sequence
{
    [self selectedUser];
}

#pragma mark - Internal Methods

- (void)updateCreationInfoContainerWithSequence:(VSequence *)sequence
{
    self.creationInfoContainer.sequence = self.sequence;
}

- (void)updateProfileButtonWithSequence:(VSequence *)sequence
{
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.displayOriginalPoster.pictureUrl]
                                  forState:UIControlStateNormal];
}

- (void)updateCaptionViewWithSequence:(VSequence *)sequence
{
    self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name ?: @""
                                                                          attributes:[[self class] sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    attributes[ NSFontAttributeName ] = [[dependencyManager fontForKey:VDependencyManagerHeading2FontKey] fontWithSize:19];
    
    paragraphStyle.maximumLineHeight = 25;
    paragraphStyle.minimumLineHeight = 25;
    
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end

#pragma mark - Category Implementations

@implementation VHermesStreamCollectionViewCell (Sizing)

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize size = CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
    
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        CGFloat insetWidth = size.width - kTextInsets.left - kTextInsets.right;
        // Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:insetWidth
                                             andAttributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
        size.height += textSize.height + kTextInsets.top + kTextInsets.bottom;
    }
    else
    {
        size.height += kMinimumCaptionContainerHeight;
    }
    
    return size;
}

@end

@implementation VHermesStreamCollectionViewCell (UpdateHooks)

- (void)updateCommentsForSequence:(VSequence *)sequence
{
    NSString *commentCount = (self.sequence.commentCount.integerValue != 0) ? [self.numberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
    [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
}

- (void)updateUsernameForSequence:(VSequence *)sequence
{
    [self updateCreationInfoContainerWithSequence:sequence];
}

- (void)updateUserAvatarForSequence:(VSequence *)sequence
{
    [self updateProfileButtonWithSequence:sequence];
}

@end
