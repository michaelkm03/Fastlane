//
//  VEStreamCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEStreamCollectionViewCell.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "VRoundedCommentButton.h"

// Models
#import "VUser+Fetcher.h"
#import "VSequence+Fetcher.h"

static const CGFloat kInfoContainerHeight = 81.0f;
static const CGFloat kLeadingTrailingSpace = 22.0f;
static const CGFloat kAvatarSize = 28.5;
static const CGFloat kSpaceAvatarToLabels = 3.0f;

@interface VEStreamCollectionViewCell ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIImageView *previewImageView;
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
        
        // If we already created our content views put them in the container
        if (self.previewImageView != nil)
        {
            [self.contentContainerView addSubview:self.previewImageView];
            [self.contentContainerView v_addFitToParentConstraintsToSubview:self.previewImageView];
        }
        
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
    _sequence = sequence;
    
    if ([sequence isText])
    {
        VLog(@"%@, text cell", self);
    }
    else if ([sequence isPoll])
    {
        VLog(@"%@, poll cell", self);
    }
    else if ([sequence isVideo])
    {
        VLog(@"%@, video cell", self);
    }
    else if ([sequence isImage])
    {
        VLog(@"%@, image cell", self);
        if (self.previewImageView == nil)
        {
            UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentContainerView addSubview:previewImageView];
            [self.contentContainerView v_addFitToParentConstraintsToSubview:previewImageView];
            self.previewImageView = previewImageView;
        }
        [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
    }
    

    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                  forState:UIControlStateNormal];
    self.creationInfoContainer.sequence = sequence;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ([self.creationInfoContainer respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.creationInfoContainer setDependencyManager:_dependencyManager];
    }
    if ([self.commentButton respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.commentButton setDependencyManager:_dependencyManager];
    }
}

@end
