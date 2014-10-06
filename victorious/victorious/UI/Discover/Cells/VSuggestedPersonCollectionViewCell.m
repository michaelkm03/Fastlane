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

@implementation VSuggestedPersonData

@end

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet UIButton *followButton;
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
    
    [self applyTheme];
}

- (void)applyTheme
{
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
}

- (void)setData:(VSuggestedPersonData *)data
{
    _data = data;
    [self populateData];
}

- (void)populateData
{
    self.descriptionLabel.text = [VFollowersTextFormatter shortLabelWithNumberOfFollowersObject:self.data.numberOfFollowers];
    
    self.usernameLabel.text = self.data.username;
    
    if ( _data.pictureUrl != nil )
    {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:self.data.pictureUrl]];
    }
    
    [self updateFollowing];
}

- (void)updateFollowing
{
    if ( self.data.isMainUserFollowing )
    {
        [self.followButton setImage:[VSuggestedPersonCollectionViewCell followedImage] forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setImage:[VSuggestedPersonCollectionViewCell followImage] forState:UIControlStateNormal];
    }
}

- (IBAction)onFollow:(id)sender
{
    if ( self.delegate == nil )
    {
        return;
    }
    
    if ( self.data.isMainUserFollowing )
    {
        self.data.isMainUserFollowing = NO;
        [self.delegate unfollowPerson:self.data];
    }
    else
    {
        self.data.isMainUserFollowing = YES;
        [self.delegate followPerson:self.data];
    }
    
    [self updateFollowing];
}

@end
