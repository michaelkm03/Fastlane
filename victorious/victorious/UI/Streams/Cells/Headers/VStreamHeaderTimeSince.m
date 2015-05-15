//
//  VStreamHeaderTimeSince.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamHeaderTimeSince.h"

// Libraries
#import <FBKVOController.h>

// Views + Helpers
#import "VSequenceActionsDelegate.h"
#import "VFlexBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VCreationInfoContainer.h"
#import "VDefaultProfileButton.h"
#import "VLargeNumberFormatter.h"
#import "UIView+AutoLayout.h"
#import "VTimeSinceWidget.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

static const CGFloat kLeadingTrailingHeaderSpace = 11.0f;
static const CGFloat kAvatarSize = 32.0f;
static const CGFloat kSpaceAvatarToLabels = 7.0f;

@interface VStreamHeaderTimeSince ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VFlexBar *actionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) VTimeSinceWidget *timeSinceWidget;

@end

@implementation VStreamHeaderTimeSince

#pragma mark - Init

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
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
        self.creationInfoContainer.shouldShowTimeSince = NO;
        
        self.timeSinceWidget = [[VTimeSinceWidget alloc] initWithFrame:CGRectZero];
        if ([self.timeSinceWidget respondsToSelector:@selector(setDependencyManager:)])
        {
            [self.timeSinceWidget setDependencyManager:self.dependencyManager];
        }
        self.timeSinceWidget.sequence = self.sequence;
        
        self.actionBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace],
                                       button,
                                       [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceAvatarToLabels],
                                       creationContainer,
                                       self.timeSinceWidget,
                                       [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace]];
        [self.actionBar v_addPinToTopBottomToSubview:self.creationInfoContainer];
        [self updateUserAvatarForSequence:self.sequence];
        [self updateInfoContainerForSequence:self.sequence];
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [self unobserveSequence:_sequence];
    
    _sequence = sequence;
    
    self.creationInfoContainer.sequence = sequence;
    self.timeSinceWidget.sequence = sequence;
    [self.profileButton setProfileImageURL:[NSURL URLWithString:sequence.displayOriginalPoster.pictureUrl]
                                  forState:UIControlStateNormal];
    
    [self observeSequence:_sequence];
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

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ([self.creationInfoContainer respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.creationInfoContainer setDependencyManager:dependencyManager];
    }
    if ([self.timeSinceWidget respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.timeSinceWidget setDependencyManager:dependencyManager];
    }
}

#pragma mark - Observers

- (void)unobserveSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(name))];
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(pictureUrl))];
}

- (void)observeSequence:(VSequence *)sequence
{
    __weak typeof(self) welf = self;
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(name))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateInfoContainerForSequence:welf.sequence];
     }];
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(pictureUrl))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateInfoContainerForSequence:welf.sequence];
     }];
}

#pragma mark - Internal Methods

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
