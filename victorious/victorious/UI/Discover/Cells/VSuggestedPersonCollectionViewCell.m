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
#import "VFollowersTextFormatter.h"
#import "VFollowUserControl.h"

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet VFollowUserControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, assign) BOOL shouldAnimateFollowing;

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
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.shouldAnimateFollowing = NO;
}

- (void)applyTheme
{
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
}

- (void)setUser:(VUser *)user
{
    _user = user;
    [self populateData];
}

- (void)populateData
{
    self.descriptionLabel.text = [VFollowersTextFormatter shortLabelWithNumberOfFollowersObject:self.user.numberOfFollowers];
    
    self.usernameLabel.text = self.user.name;
    
    if ( self.user.pictureUrl != nil )
    {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:self.user.pictureUrl]];
    }
    
    [self updateFollowing];
    
    [self applyTheme];
}

- (void)updateFollowing
{
    [self.followButton setFollowing:self.user.isFollowing.boolValue
                           animated:self.shouldAnimateFollowing];
    if (self.shouldAnimateFollowing)
    {
        self.shouldAnimateFollowing = NO;
    }
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
    
    self.shouldAnimateFollowing = YES;
    
    [self updateFollowing];
}

@end
