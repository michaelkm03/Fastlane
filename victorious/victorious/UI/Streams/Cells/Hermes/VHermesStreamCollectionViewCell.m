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
#import "VRoundedCommentButton.h"
#import "VLargeNumberFormatter.h"
#import "VSlantView.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

static const CGFloat kLeadingTrailingHeaderSpace = 15.0f;
static const CGFloat kAvatarSize = 32.0f;
static const CGFloat kSpaceAvatarToLabels = 3.0f;
static const CGFloat kHeaderHeight = 62.0f;
static const CGFloat kSlantHeight = 58.0f;

@interface VHermesStreamCollectionViewCell () <CCHLinkTextViewDelegate>

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *captionContainerView;
@property (nonatomic, strong) VActionBar *headerBar;
@property (nonatomic, strong) VActionBar *actionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) VSlantView *slantView;
@property (nonatomic, strong) VRoundedCommentButton *commentButton;
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
    
    return [NSString stringWithString:identifier];
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    if (!self.hasLayedOutViews)
    {
        [self.contentView v_addFitToParentConstraintsToSubview:self.contentContainerView]; // remove me
        [self.contentView addSubview:self.captionContainerView];
        [self.contentView v_addPinToLeadingTrailingToSubview:self.captionContainerView];
        [self v_addPinToLeadingTrailingToSubview:self.contentContainerView]; // restoer me
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentContainerView][captionContainer(75)]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"contentContainerView":self.contentContainerView,
                                                                               @"captionContainer": self.captionContainerView}]];
        [self.contentContainerView addSubview:self.slantView];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.slantView];
        

        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[slantView(kSlantHeight)]|"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"kSlantHeight": @(kSlantHeight)}
                                                                                            views:@{@"slantView":self.slantView}]];
        
        [self.contentContainerView addSubview:self.headerBar];
        [self.contentContainerView v_addPinToLeadingTrailingToSubview:self.headerBar];
        [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerBar(kHeaderHeight)]"
                                                                                          options:kNilOptions
                                                                                          metrics:@{@"kHeaderHeight":@(kHeaderHeight)}
                                                                                            views:@{@"headerBar":self.headerBar}]];
        


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

- (VHashTagTextView *)captionTextView
{
    if (_captionTextView == nil)
    {
        self.captionTextView = [[VHashTagTextView alloc] initWithFrame:CGRectZero];
        self.captionTextView.linkDelegate = self;
        self.captionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.captionTextView.backgroundColor = [UIColor clearColor];
    }
    return _captionTextView;
}

- (UIView *)contentContainerView
{
    if (_contentContainerView == nil)
    {
        UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:contentContainerView];
        _contentContainerView = contentContainerView;
        [_contentContainerView addSubview:self.previewView];
        [_contentContainerView v_addFitToParentConstraintsToSubview:self.previewView];
    }
    
    return _contentContainerView;
}

- (UIView *)captionContainerView
{
    if (_captionContainerView == nil)
    {
        UIView *captionContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        captionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_captionContainerView];
        _captionContainerView = captionContainerView;
    }
    return _captionContainerView;
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
        
        headerBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace],
                                  button,
                                  [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceAvatarToLabels],
                                  creationContainer,
                                  commentButton,
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
        [self.commentButton setDependencyManager:dependencyManager];
    }
    VBackground *slantBackground = [dependencyManager background];
    if ([slantBackground isKindOfClass:[VSolidColorBackground class]])
    {
        self.slantView.slantColor = ((VSolidColorBackground *)slantBackground).backgroundColor;
        self.captionContainerView.backgroundColor = ((VSolidColorBackground *)slantBackground).backgroundColor;
    }
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self selectedHashTag:value];
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
    }
    else
    {
    }
}

@end

@implementation VHermesStreamCollectionViewCell (Sizing)

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds) + 50);
}

@end


@implementation VHermesStreamCollectionViewCell (UpdateHooks)

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
