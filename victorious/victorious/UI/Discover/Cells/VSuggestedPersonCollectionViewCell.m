//
//  VSuggestedPersonCollectionViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPersonCollectionViewCell.h"
#import "VThemeManager.h"
#import "VDefaultProfileImageView.h"
#import "VFollowUserControl.h"
#import "VFollowersTextFormatter.h"
#import "VDependencyManager.h"

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet VFollowUserControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

- (IBAction)onFollow:(id)sender;

@end

@implementation VSuggestedPersonCollectionViewCell

+ (UIImage *)followedImage
{
    static UIImage *followedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followedImage = [UIImage imageNamed:@"folllowedIcon"];
                  });
    return followedImage;
}

+ (UIImage *)followImage
{
    static UIImage *followImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followImage = [UIImage imageNamed:@"folllowIcon"];
                  });
    return followImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat radius = self.profileImageView.bounds.size.width * 0.5f;
    self.profileImageView.layer.cornerRadius = radius;
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( _dependencyManager != nil )
    {
        self.usernameLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.usernameLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.descriptionLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.followButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (void)setUser:(VUser *)user
{
    _user = user;
    [self populateData];
    [self updateFollowingAnimated:NO];
}

- (void)setUser:(VUser *)user
       animated:(BOOL)animated
{
    if (!animated)
    {
        self.user = user;
        return;
    }
    _user = user;
    [self populateData];
    [self updateFollowingAnimated:animated];
}

- (void)populateData
{
    NSInteger intValue = self.user.numberOfFollowers.integerValue;
    self.descriptionLabel.text = [VFollowersTextFormatter followerTextWithNumberOfFollowers:intValue];
    
    self.usernameLabel.text = self.user.name;
    
    if ( self.user.pictureUrl != nil )
    {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:self.user.pictureUrl]];
    }
}

- (void)updateFollowingAnimated:(BOOL)animated
{
    [self.followButton setFollowing:self.user.isFollowing.boolValue
                           animated:animated];
}

- (IBAction)onFollow:(id)sender
{
    if ( self.delegate == nil )
    {
        return;
    }
    
    if ( self.user.isFollowing.boolValue )
    {
        [self.delegate unfollowPerson:self.user];
    }
    else
    {
        [self.delegate followPerson:self.user];
    }
}

@end
