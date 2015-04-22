//
//  VEStreamCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEStreamCollectionViewCell.h"

// Views + Helpers
#import "UIView+AutoLayout.h"
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "VRoundedCommentButton.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

static const CGFloat kInfoContainerHeight = 81.0f;
static const CGFloat kLeadingTrailingSpace = 22.0f;
static const CGFloat kAvatarSize = 28.5;
static const CGFloat kSpaceAvatarToLabels = 3.0f;

@interface VEStreamCollectionViewCell ()

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) VActionBar *sequenceInfoActionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) VRoundedCommentButton *commentButton;

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
    else
    {
        VLog(@"%@, doesn't support sequence type for sequence: %@", NSStringFromClass(self), sequence);
    }
    
    return [NSString stringWithString:identifier];
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
#warning Remove Me
    self.backgroundColor = [UIColor blackColor];
    
    if (!self.hasLayedOutViews)
    {
        // Layout containers
        UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        contentContainerView.backgroundColor = [UIColor orangeColor];
        [self addSubview:contentContainerView];
        self.contentContainerView = contentContainerView;
        
        [self.contentContainerView addSubview:self.previewView];
        [self.contentContainerView v_addFitToParentConstraintsToSubview:self.previewView];
        
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
        creationContainer.sequence = self.sequence;
        if ([creationContainer respondsToSelector:@selector(setDependencyManager:)])
        {
            [creationContainer setDependencyManager:self.dependencyManager];
        }
        [creationContainer v_addHeightConstraint:44.0f];
        self.creationInfoContainer = creationContainer;
        
        VRoundedCommentButton *commentButton = [[VRoundedCommentButton alloc] initWithFrame:CGRectZero];
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
    
    [super layoutSubviews];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                  forState:UIControlStateNormal];
    self.creationInfoContainer.sequence = sequence;
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

@end
