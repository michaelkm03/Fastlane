//
//  VEStreamCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEStreamCollectionViewCell.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VHashTagTextView.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>
#import "UIView+AutoLayout.h"
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "VRoundedCommentButton.h"
#import "VLargeNumberFormatter.h"
#import "VLinearGradientView.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

static const CGFloat kInfoContainerHeight = 81.0f;
static const CGFloat kLeadingTrailingSpace = 22.0f;
static const CGFloat kAvatarSize = 28.5;
static const CGFloat kSpaceAvatarToLabels = 3.0f;
static const CGFloat kGradientEndAlpha = 0.15f;
static const CGFloat kGradientHeight = 78.0f;

@interface VEStreamCollectionViewCell () <CCHLinkTextViewDelegate>

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) VActionBar *sequenceInfoActionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) VRoundedCommentButton *commentButton;
@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;
@property (nonatomic, strong) VLinearGradientView *linearGradientView;
@property (nonatomic, strong) VHashTagTextView *captionTextView;

@end

@implementation VEStreamCollectionViewCell

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
    
    return [NSString stringWithString:identifier];
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    if (!self.hasLayedOutViews)
    {
        // Layout containers
        UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentContainerView];
        self.contentContainerView = contentContainerView;
        
        [self.contentContainerView addSubview:self.previewView];
        [self.contentContainerView v_addFitToParentConstraintsToSubview:self.previewView];
        
        self.linearGradientView = [[VLinearGradientView alloc] initWithFrame:CGRectZero];
        [self.linearGradientView setColors:@[[[UIColor blackColor] colorWithAlphaComponent:kGradientEndAlpha],
                                             [UIColor blackColor]]];
        [self.contentContainerView addSubview:self.linearGradientView];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.linearGradientView];
        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[linearGradientView(height)]|"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"height":@(kGradientHeight)}
                                                                                            views:@{@"linearGradientView":self.linearGradientView}]];
        
        self.captionTextView = [[VHashTagTextView alloc] initWithFrame:CGRectZero];
        self.captionTextView.linkDelegate = self;
        self.captionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.captionTextView.backgroundColor = [UIColor clearColor];

        [self.linearGradientView addSubview:self.captionTextView];
        [self.linearGradientView v_addFitToParentConstraintsToSubview:self.captionTextView];
        
        UIView *contentInfoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentInfoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentInfoContainerView];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(contentContainerView, contentInfoContainerView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentContainerView]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentContainerView][contentInfoContainerView]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        [contentContainerView addConstraint:[NSLayoutConstraint constraintWithItem:contentContainerView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:contentContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentInfoContainerView]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        [contentInfoContainerView v_addHeightConstraint:kInfoContainerHeight];
        
        VActionBar *actionBar = [[VActionBar alloc] init];
        actionBar.translatesAutoresizingMaskIntoConstraints = NO;
        [contentInfoContainerView addSubview:actionBar];
        [contentInfoContainerView v_addPinToLeadingTrailingToSubview:actionBar];
        [contentInfoContainerView addConstraint:[NSLayoutConstraint constraintWithItem:contentInfoContainerView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:actionBar
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:0.0f]];
        [actionBar v_addHeightConstraint:55.0f];
        self.sequenceInfoActionBar = actionBar;
        
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
        [creationContainer v_addHeightConstraint:44.0f];
        self.creationInfoContainer = creationContainer;
        
        VRoundedCommentButton *commentButton = [[VRoundedCommentButton alloc] initWithFrame:CGRectZero];
        [commentButton addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
        commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.commentButton = commentButton;
        if ([self.commentButton respondsToSelector:@selector(setDependencyManager:)])
        {
            [self.commentButton setDependencyManager:self.dependencyManager];
        }
        
        actionBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingSpace],
                                  button,
                                  [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceAvatarToLabels],
                                  creationContainer,
                                  commentButton,
                                  [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingSpace]];
        
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
    
    [self updateProfileButtonWithSequence:sequence];
    [self updateCreationInfoContainerWithSequence:sequence];
    [self updateCaptionViewWithSequence:sequence];
}

#pragma mark - Property Accessors

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
        [self.commentButton setDependencyManager:dependencyManager];
    }
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self selectedHashTag:value];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.contentView;
}

#pragma mark - Internal Methods

- (void)updateCreationInfoContainerWithSequence:(VSequence *)sequence
{
    self.creationInfoContainer.sequence = self.sequence;
}

- (void)updateProfileButtonWithSequence:(VSequence *)sequence
{
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                  forState:UIControlStateNormal];
}

- (void)updateCaptionViewWithSequence:(VSequence *)sequence
{
    if ([[self class] canOverlayContentForSequence:sequence])
    {
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:sequence.name ?: @""
                                                                              attributes:@{
                                                                                           NSFontAttributeName:[self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
                                                                                           NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]
                                                                                           }];
        self.linearGradientView.hidden = NO;
    }
    else
    {
        self.linearGradientView.hidden = YES;
    }
}

@end


@implementation VEStreamCollectionViewCell (UpdateHooks)

- (void)updateCommentsForSequence:(VSequence *)sequence
{
    NSString *commentCount = self.sequence.commentCount.integerValue ? [self.numberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
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
