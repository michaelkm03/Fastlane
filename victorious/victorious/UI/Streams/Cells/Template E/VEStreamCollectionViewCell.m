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
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"

// Models
#import "VUser+Fetcher.h"
#import "VSequence+Fetcher.h"

static const CGFloat kInfoContainerHeight = 81.0f;

@interface VEStreamCollectionViewCell ()

@property (nonatomic, assign) BOOL hasLayedOutViews;

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) VActionBar *sequenceInfoActionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;

@end

@implementation VEStreamCollectionViewCell

- (void)layoutSubviews
{
    if (!self.hasLayedOutViews)
    {
        // Layout containers
        UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        contentContainerView.backgroundColor = [UIColor orangeColor];
        [self addSubview:contentContainerView];
        
        UIView *contentInfoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        contentInfoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        contentInfoContainerView.backgroundColor = [UIColor purpleColor];
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
        
        // Layout Detail Views
        UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentContainerView addSubview:previewImageView];
        [contentContainerView v_addFitToParentConstraintsToSubview:previewImageView];
        self.previewImageView = previewImageView;
        
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
        [button v_addHeightConstraint:44.0f];
        [button v_addWidthConstraint:44.0f];
        self.profileButton = button;
        
        VCreationInfoContainer *creationContainer = [[VCreationInfoContainer alloc] initWithFrame:CGRectZero];
        creationContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [creationContainer v_addHeightConstraint:44.0f];
        self.creationInfoContainer = creationContainer;
        actionBar.actionItems = @[button,
                                  creationContainer];
        
        
        self.hasLayedOutViews = YES;
    }
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                  forState:UIControlStateNormal];
    self.creationInfoContainer.sequence = sequence;
}

@end
