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
#import "VLargeNumberFormatter.h"

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet VFollowUserControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

- (IBAction)onFollow:(id)sender;

@end

@implementation VSuggestedPersonCollectionViewCell

+ (VLargeNumberFormatter *)numberFormatter
{
    static VLargeNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      formatter = [[VLargeNumberFormatter alloc] init];
                  });
    return formatter;
}

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

- (void)applyTheme
{
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
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
    self.descriptionLabel.text = [self followerTextWithNumberOfFollowers:self.user.numberOfFollowers.integerValue];
    
    self.usernameLabel.text = self.user.name;
    
    if ( self.user.pictureUrl != nil )
    {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:self.user.pictureUrl]];
    }
    
    [self applyTheme];
}

- (NSString *)followerTextWithNumberOfFollowers:(NSInteger)numberOfFollwers
{
    NSString *numberString = [[[self class] numberFormatter] stringForInteger:numberOfFollwers];
    
    if ( numberOfFollwers == 0 )
    {
        return NSLocalizedString( @"SuggestedFollowersNone", nil);
    }
    else if ( numberOfFollwers == 1 )
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersSing", nil);
        return [NSString stringWithFormat:format, numberString];
    }
    else if ( numberOfFollwers >= 1000 )
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersK", nil);
        return [NSString stringWithFormat:format, numberString];
    }
    else
    {
        NSString *format = NSLocalizedString( @"SuggestedFollowersPlur", nil);
        return [NSString stringWithFormat:format, numberString];
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
