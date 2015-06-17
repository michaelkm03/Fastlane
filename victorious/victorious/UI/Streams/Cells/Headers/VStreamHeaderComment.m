//
//  VStreamHeaderComment.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamHeaderComment.h"

// Libraries
#import <FBKVOController.h>

// Dependencies
#import "VDependencyManager.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

// Views + Helpers
#import "VSequenceActionsDelegate.h"
#import "VFlexBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "UIView+AutoLayout.h"
#import "VLargeNumberFormatter.h"

static const CGFloat kLeadingTrailingMargin = 20.0f;
static const CGFloat kAvatarSize = 32.0f;
static const CGFloat kItemSpacing = 5.0f;

@interface VStreamHeaderComment ()

@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VFlexBar *actionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;

@end

@implementation VStreamHeaderComment

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
    _actionBar = [[VFlexBar alloc] initWithFrame:CGRectZero];
    [self addSubview:_actionBar];
    [self v_addFitToParentConstraintsToSubview:_actionBar];
    _numberFormatter = [[VLargeNumberFormatter alloc] init];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    if (self.actionBar.actionItems == nil)
    {
        VDefaultProfileButton *button = [[VDefaultProfileButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button v_addHeightConstraint:kAvatarSize];
        [button v_addWidthConstraint:kAvatarSize];
        [button addTarget:self action:@selector(selectedUserButton:) forControlEvents:UIControlEventTouchUpInside];
        self.profileButton = button;
        
        VCreationInfoContainer *creationContainer = [[VCreationInfoContainer alloc] initWithFrame:CGRectZero];
        creationContainer.translatesAutoresizingMaskIntoConstraints = NO;
        if ([creationContainer respondsToSelector:@selector(setDependencyManager:)])
        {
            [creationContainer setDependencyManager:self.dependencyManager];
        }

        self.creationInfoContainer = creationContainer;
        if ([self.creationInfoContainer respondsToSelector:@selector(setDependencyManager:)])
        {
            [self.creationInfoContainer setDependencyManager:self.dependencyManager];
        }
        
        self.actionBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingMargin],
                                       self.profileButton,
                                       [VActionBarFixedWidthItem fixedWidthItemWithWidth:kItemSpacing],
                                       self.creationInfoContainer,
                                       [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingMargin]];
        [self.actionBar v_addPinToTopBottomToSubview:self.creationInfoContainer];
        [self updateUserAvatarForSequence:self.sequence];
        [self updateInfoContainerForSequence:self.sequence];
    }
}

#pragma mark - Target/Action

- (void)selectedUserButton:(VDefaultProfileButton *)profileButton
{
    UIResponder<VSequenceActionsDelegate> *targetForUserSelection = [self targetForAction:@selector(selectedUser:onSequence:fromView:)
                                                                               withSender:self];
    if (targetForUserSelection == nil)
    {
        NSAssert(false, @"We need an object in the responder chain for user selection.");
    }
    [targetForUserSelection selectedUser:self.sequence.displayOriginalPoster
                              onSequence:self.sequence
                                fromView:self];
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self updateInfoContainerForSequence:sequence];
    [self updateUserAvatarForSequence:sequence];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ([self.creationInfoContainer respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.creationInfoContainer setDependencyManager:dependencyManager];
    }
}

- (void)updateInfoContainerForSequence:(VSequence *)sequence
{
    self.creationInfoContainer.sequence = self.sequence;
}

- (void)updateUserAvatarForSequence:(VSequence *)sequence
{
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.displayOriginalPoster.pictureUrl]
                                  forState:UIControlStateNormal];
}

@end
