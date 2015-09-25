//
//  VStreamHeaderTimeSince.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellHeader.h"

// Dependencies
#import "VDependencyManager.h"

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
#import "VFollowControl.h"
#import "VFollowResponder.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VObjectManager.h"

// Frameworks
@import KVOController;

static const CGFloat kLeadingTrailingHeaderSpace = 11.0f;
static const CGFloat kAvatarSize = 32.0f;
static const CGFloat kSpaceAvatarToLabels = 7.0f;
static const CGFloat kSpaceLabelsToTimestamp = kSpaceAvatarToLabels;

@interface VStreamCellHeader ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VFlexBar *actionBar;
@property (nonatomic, strong) VDefaultProfileButton *profileButton;
@property (nonatomic, strong) VCreationInfoContainer *creationInfoContainer;
@property (nonatomic, strong) VTimeSinceWidget *timeSinceWidget;
@property (nonatomic, strong) VFollowControl *followControl;
@property (nonatomic, assign) BOOL shouldShowFollowControl;

@end

@implementation VStreamCellHeader

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
    
    if ( [self actionBarNeedsSetup] )
    {
        VDefaultProfileButton *button = [[VDefaultProfileButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button v_addHeightConstraint:kAvatarSize];
        [button v_addWidthConstraint:kAvatarSize];
        [button addTarget:self action:@selector(selectedUserButton:) forControlEvents:UIControlEventTouchUpInside];
        self.profileButton = button;
        self.profileButton.dependencyManager = self.dependencyManager;
        self.profileButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        
        VCreationInfoContainer *creationContainer = [[VCreationInfoContainer alloc] initWithFrame:CGRectZero];
        creationContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        if ([creationContainer respondsToSelector:@selector(setDependencyManager:)])
        {
            [creationContainer setDependencyManager:self.dependencyManager];
        }
        self.creationInfoContainer = creationContainer;
        self.creationInfoContainer.shouldShowTimeSince = NO;
        
        [self updateActionBarActionItems];
        [self.actionBar v_addPinToTopBottomToSubview:self.creationInfoContainer];
        [self updateUserAvatarForSequence:self.sequence];
        [self updateInfoContainerForSequence:self.sequence];
    }
}

- (void)updateActionBarActionItems
{
    UIView *rightMostWidget = self.shouldShowFollowControl ? self.followControl : self.timeSinceWidget;
    self.actionBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace],
                                   self.profileButton,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceAvatarToLabels],
                                   self.creationInfoContainer,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kSpaceLabelsToTimestamp],
                                   rightMostWidget,
                                   [VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingHeaderSpace]];
}

- (BOOL)actionBarNeedsSetup
{
    return self.actionBar.actionItems == nil;
}

- (void)setSequence:(VSequence *)sequence
{
    [self unobserveSequence:_sequence];
    
    _sequence = sequence;
    
    BOOL shouldShowFollowControl = ![self.sequence.user isEqual:[[VObjectManager sharedManager] mainUser]] && !self.sequence.user.isFollowedByMainUser.boolValue;
    if ( self.shouldShowFollowControl != shouldShowFollowControl )
    {
        self.shouldShowFollowControl = shouldShowFollowControl;
        if ( ![self actionBarNeedsSetup] )
        {
            [self updateActionBarActionItems];
        }
    }
    if ( self.shouldShowFollowControl )
    {
        self.followControl.controlState = [VFollowControl controlStateForFollowing:self.sequence.user.isFollowedByMainUser.boolValue];
    }
    else
    {
        self.timeSinceWidget.sequence = self.sequence;
    }
    
    self.creationInfoContainer.sequence = sequence;
    self.profileButton.user = sequence.displayOriginalPoster;
    
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
    self.profileButton.dependencyManager = dependencyManager;
    self.profileButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

#pragma mark - Observers

- (void)unobserveSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(name))];
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(pictureUrl))];
    [self.KVOController unobserve:sequence.user
                          keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
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
                       keyPaths:@[NSStringFromSelector(@selector(isFollowedByMainUser))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, VSequence *sequence, NSDictionary *change)
     {
         [welf updateFollowStatus];
     }];
    
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(pictureUrl))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateInfoContainerForSequence:welf.sequence];
     }];
}

- (void)updateFollowStatus
{
    [self.followControl setControlState:[VFollowControl controlStateForFollowing:self.sequence.user.isFollowedByMainUser.boolValue] animated:YES];
}

- (IBAction)followUnfollowUser:(VFollowControl *)sender
{
    if ( sender.controlState == VFollowControlStateLoading )
    {
        return;
    }
    
    void (^authorizedBlock)() = ^
    {
        [sender setControlState:VFollowControlStateLoading
                       animated:YES];
    };
    
    void (^completionBlock)(VUser *) = ^(VUser *userActedOn)
    {
        [self updateFollowStatus];
    };
    
    if ( sender.controlState == VFollowControlStateFollowed )
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
        
        [followResponder unfollowUser:self.sequence.user
                  withAuthorizedBlock:authorizedBlock
                        andCompletion:completionBlock
                   fromViewController:nil
                       withScreenName:VFollowSourceScreenSleekCell];
    }
    else
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
        
        [followResponder followUser:self.sequence.user
                withAuthorizedBlock:authorizedBlock
                      andCompletion:completionBlock
                 fromViewController:nil
                     withScreenName:VFollowSourceScreenSleekCell];
    }
}

#pragma mark - Internal Methods

- (void)updateInfoContainerForSequence:(VSequence *)sequence
{
    self.creationInfoContainer.sequence = self.sequence;
}

- (void)updateUserAvatarForSequence:(VSequence *)sequence
{
    self.profileButton.user = sequence.displayOriginalPoster;
}

#pragma mark - Lazy properties

- (VTimeSinceWidget *)timeSinceWidget
{
    if ( _timeSinceWidget == nil )
    {
        VTimeSinceWidget *timeSinceWidget = [[VTimeSinceWidget alloc] initWithFrame:CGRectZero];
        if ([timeSinceWidget respondsToSelector:@selector(setDependencyManager:)])
        {
            [timeSinceWidget setDependencyManager:self.dependencyManager];
        }
        timeSinceWidget.sequence = self.sequence;
        _timeSinceWidget = timeSinceWidget;
    }
    
    return _timeSinceWidget;
}

- (VFollowControl *)followControl
{
    if ( _followControl == nil )
    {
        VFollowControl *followControl = [[VFollowControl alloc] initWithFrame:CGRectZero];
        followControl.dependencyManager = self.dependencyManager;
        [followControl addTarget:self action:@selector(followUnfollowUser:) forControlEvents:UIControlEventTouchUpInside];
        //Disallow constraints created by the autoresizing mask to allow the action bar that contains it to adjust this control as needed.
        followControl.translatesAutoresizingMaskIntoConstraints = NO;
        _followControl = followControl;
    }
    
    return _followControl;
}

@end