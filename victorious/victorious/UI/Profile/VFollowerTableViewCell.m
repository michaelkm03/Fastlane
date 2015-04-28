//
//  VFollowerTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowerTableViewCell.h"

// Models + Helpers
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VDefaultProfileButton.h"
#import "VFollowUserControl.h"
#import "UIImageView+VLoadingAnimations.h"
#import <KVOController/FBKVOController.h>

static const CGFloat kFollowerCellHeight = 50.0f;

@interface VFollowerTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *profileName;
@property (nonatomic, weak) IBOutlet UILabel *profileLocation;
@property (nonatomic, weak) IBOutlet VFollowUserControl *followControl;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFollowerTableViewCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass(self);
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kFollowerCellHeight);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.bounds) / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 1.0;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.97
                                                         alpha:1.0];
}

#pragma mark - Public

- (void)setProfile:(VUser *)profile
{
    if (_profile == profile)
    {
        return;
    }
    
    [self.KVOController unobserve:_profile
                          keyPath:NSStringFromSelector(@selector(followers))];
    
    _profile = profile;

    __weak typeof(self) welf = self;
    [self.KVOController observe:profile
                       keyPaths:@[NSStringFromSelector(@selector(followers))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateFollowingAnimated:YES];
     }];
    
    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.profileImageView fadeInImageAtURL:[NSURL URLWithString:profile.pictureUrl]
                           placeholderImage:defaultImage];
    self.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.profileName.text = profile.name;
    self.profileLocation.text = profile.location;

    [self updateFollowingAnimated:NO];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.profileName.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.profileLocation.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.followControl.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.profileImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

#pragma mark - Target/Action

- (IBAction)tappedFollowControl:(VFollowUserControl *)sender
{
    if (self.followAction != nil)
    {
        self.followAction(!sender.following, self.profile);
    }
}

#pragma mark - Private Methods

- (void)updateFollowingAnimated:(BOOL)animated
{
    // If this is the currently logged in user, then hide the follow button
    VUser *me = [[VObjectManager sharedManager] mainUser];
    self.followControl.hidden = (self.profile == me);
    [self.followControl setFollowing:[me.following containsObject:self.profile]
                            animated:animated];
}

@end
