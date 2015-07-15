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

static NSString * const kTextTitleColorKey = @"color.text.label1";

@interface VSuggestedUserCell ()

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
    
    self.thumbnailsDataSource = [[VContentThumbnailsDataSource alloc] init];
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
}

- (void)setUser:(VUser *)user
{
    _user = user;
    
    self.usernameTextView.text = _user.name;
    
    self.thumbnailsDataSource.sequences = user.recentSequences.array;
    [self.thumbnailsViewController.collectionView reloadData];
    
    if ( _user.pictureUrl != nil )
    {
        [self.userProfileImage setProfileImageURL:[NSURL URLWithString:_user.pictureUrl]];
    }
    
    self.followButton.following = self.user.isFollowedByMainUser.boolValue;
}

- (void)applyStyle
{
    self.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.usernameTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self forKey:@"background.detail"];
}

- (IBAction)followButtonPressed:(VFollowControl *)sender
{
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                      withSender:nil];
    
    NSAssert(followResponder != nil, @"Need a VFollowingResponder higher up the chain to communicate following commands.");
    sender.enabled = NO;
    sender.showActivityIndicator = YES;

    if ( self.user.isFollowedByMainUser.boolValue )
    {
        [followResponder unfollowUser:self.user withCompletion:^(VUser *userActedOn)
         {
             [sender setFollowing:self.user.isFollowedByMainUser.boolValue animated:YES];
             sender.showActivityIndicator = NO;
             sender.enabled = YES;
         }];
    }
    else
    {
        [followResponder followUser:self.user withCompletion:^(VUser *userActedOn)
         {
             [sender setFollowing:self.user.isFollowedByMainUser.boolValue animated:YES];
             sender.showActivityIndicator = NO;
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
