//
//  VSuggestedUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUserCell.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VFollowUserControl.h"
#import "VFollowResponder.h"
#import "VUser.h"
#import "UIView+AutoLayout.h"
#import "UIResponder+VResponderChain.h"
#import "VDefaultProfileImageView.h"

static NSString * const kTextTitleColorKey = @"color.text.label1";
static NSString * const kTextBodyColorKey = @"color.text.label2";

@interface VSuggestedUserCell ()

@property (nonatomic, strong) VFollowUserControl *followButton;

@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *userProfileImage;
@property (nonatomic, weak) IBOutlet UITextView *usernameTextView;
@property (nonatomic, weak) IBOutlet UITextView *userTagLingTextView;
@property (nonatomic, weak) IBOutlet UIView *followButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *userStreamContainerView;

@property (nonatomic, strong) VUser *user;

@end

@implementation VSuggestedUserCell

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass( [self class] );
}

- (void)awakeFromNib
{
    self.followButton = [[VFollowUserControl alloc] initWithFrame:self.followButtonContainerView.bounds];
    [self.followButtonContainerView addSubview:self.followButton];
    [self.followButtonContainerView v_addFitToParentConstraintsToSubview:self.followButton];
    [self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self applyStyle];
}

- (void)setUser:(VUser *)user
{
    _user = user;
    
    self.usernameTextView.text = _user.name;
    self.userTagLingTextView.text = _user.tagline;

    if ( _user.pictureUrl != nil )
    {
        [self.userProfileImage setProfileImageURL:[NSURL URLWithString:_user.pictureUrl]];
    }
}

- (void)applyStyle
{
    self.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.usernameTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    
    self.userTagLingTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.userTagLingTextView.textColor = [self.dependencyManager colorForKey:kTextBodyColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self forKey:@"background.detail"];
}

- (IBAction)followButtonPressed:(VFollowUserControl *)sender
{
    [self v_logResponderChain];
    
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"Need a VFollowingResponder higher up the chain to communicate following commands.");
    sender.enabled = NO;
    if ( sender.following )
    {
        [followResponder unfollowUser:self.user withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
    else
    {
        [followResponder followUser:self.user withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self;
}

@end
