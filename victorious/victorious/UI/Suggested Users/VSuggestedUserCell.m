//
//  VSuggestedUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUserCell.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VFollowControl.h"
#import "VFollowResponder.h"
#import "VUser.h"
#import "UIView+AutoLayout.h"
#import "UIResponder+VResponderChain.h"
#import "VDefaultProfileImageView.h"
#import "VContentThumbnailsViewController.h"
#import "VContentThumbnailsDataSource.h"
#import "VSequence.h"
#import "victorious-Swift.h"

static NSString * const kTextTitleColorKey = @"color.text.label1";

@interface VSuggestedUserCell ()

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) NSArray *recentSequences;
@property (nonatomic, strong) VFollowControl *followButton;
@property (nonatomic, strong) VContentThumbnailsDataSource *thumbnailsDataSource;
@property (nonatomic, strong) VContentThumbnailsViewController *thumbnailsViewController;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *userProfileImage;
@property (nonatomic, weak) IBOutlet UITextView *usernameTextView;
@property (nonatomic, weak) IBOutlet UIView *followButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *userStreamContainerView;

@end

@implementation VSuggestedUserCell

+ (NSMutableDictionary *)dataSources
{
    static NSMutableDictionary *_dataSources = nil;
    if ( _dataSources == nil )
    {
        _dataSources = [[NSMutableDictionary alloc] init];
    }
    return _dataSources;
}

- (void)awakeFromNib
{
    self.followButton = [[VFollowControl alloc] initWithFrame:self.followButtonContainerView.bounds];
    [self.followButtonContainerView addSubview:self.followButton];
    [self.followButtonContainerView v_addFitToParentConstraintsToSubview:self.followButton];
    [self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.thumbnailsViewController = [[VContentThumbnailsViewController alloc] init];
    [self.userStreamContainerView addSubview:self.thumbnailsViewController.view];
    [self.userStreamContainerView v_addFitToParentConstraintsToSubview:self.thumbnailsViewController.view];
    self.userStreamContainerView.backgroundColor = [UIColor clearColor];
    
    self.thumbnailsDataSource = [[VContentThumbnailsDataSource alloc] initWithCollectionView:self.thumbnailsViewController.collectionView];
    self.thumbnailsViewController.collectionView.dataSource = self.thumbnailsDataSource;
    [self.thumbnailsDataSource registerCellsWithCollectionView:self.thumbnailsViewController.collectionView];
}

- (void)prepareForReuse
{
    self.thumbnailsDataSource.sequences = @[];
    [self.thumbnailsViewController.collectionView reloadData];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followButton.dependencyManager = dependencyManager;
    [self applyStyle];
    self.thumbnailsDataSource.dependencyManager = dependencyManager;
}

- (void)configureWithSuggestedUser:(VSuggestedUser *)suggestedUser
{
    self.user = suggestedUser.user;
    self.usernameTextView.text = self.user.name;
    if ( self.user.pictureUrl != nil )
    {
        [self.userProfileImage setProfileImageURL:[NSURL URLWithString:_user.pictureUrl]];
    }
    
    self.recentSequences = suggestedUser.recentSequences;
    self.thumbnailsDataSource.sequences = self.recentSequences;
    [self.thumbnailsViewController.collectionView reloadData];
    
    [self updateFollowingStateAnimated:NO];
}

- (void)applyStyle
{
    self.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.usernameTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self forKey:@"background.detail"];
}

- (void)updateFollowingStateAnimated:(BOOL)animated
{
    [self.followButton setControlState:[VFollowControl controlStateForFollowing:self.user.isFollowedByMainUser.boolValue] animated:animated];
}

- (IBAction)followButtonPressed:(VFollowControl *)sender
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
        [self updateFollowingStateAnimated:YES];
    };

    if ( sender.controlState == VFollowControlStateFollowed )
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
        
        [followResponder unfollowUser:self.user
                  withAuthorizedBlock:authorizedBlock
                        andCompletion:completionBlock
                   fromViewController:nil
                       withScreenName:VFollowSourceScreenRegistrationSuggestedUsers];
    }
    else
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
        
        [followResponder followUser:self.user
                withAuthorizedBlock:authorizedBlock
                      andCompletion:completionBlock
                 fromViewController:nil
                     withScreenName:VFollowSourceScreenRegistrationSuggestedUsers];
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self;
}

@end
