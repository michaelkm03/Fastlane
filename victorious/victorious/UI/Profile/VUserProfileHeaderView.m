//
//  VUserProfileHeaderView.m
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileHeaderView.h"

#import "VUser.h"

#import "VThemeManager.h"
#import "VObjectManager+Users.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"

static void * VProfileHeaderContext = &VProfileHeaderContext;

@implementation VUserProfileHeaderView

+ (instancetype)newViewWithFrame:(CGRect)frame
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VUserProfileHeaderView class]) owner:self options:nil];
    VUserProfileHeaderView *view = [nibViews objectAtIndex:0];
    view.frame = frame;
    
    return view;
}

- (void)dealloc
{
    [self.editProfileButton removeObserver:self forKeyPath:@"selected"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];
    self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followersHeader.text = NSLocalizedString(@"followers", @"");
    self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followingHeader.text = NSLocalizedString(@"following", @"");
    self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.editProfileButton.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.editProfileButton.layer.cornerRadius = 3.0;
    self.editProfileButton.layer.borderWidth = 2.0;
    
    self.followButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.followButtonActivityIndicator.center = CGPointMake(CGRectGetWidth(self.editProfileButton.frame) / 2.0, CGRectGetHeight(self.editProfileButton.frame) / 2.0);
    [self.editProfileButton addSubview:self.followButtonActivityIndicator];
    
    [self.editProfileButton addObserver:self
                         forKeyPath:@"selected"
                            options:NSKeyValueObservingOptionNew
                            context:VProfileHeaderContext];
}

- (void)setUser:(VUser *)user
{
    _user = user;
    [self.profileImageView setProfileImageURL:[NSURL URLWithString:user.pictureUrl]];
    
    // Set Profile data
    self.nameLabel.text = self.user.name;
    self.locationLabel.text = self.user.location;
    
    if (self.user.tagline && self.user.tagline.length)
    {
        self.taglineLabel.text = self.user.tagline;
    }
    else
    {
        self.taglineLabel.text = @"";
    }
    
    [[VObjectManager sharedManager] countOfFollowsForUser:self.user
                                             successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.numberOfFollowers = [resultObjects[0] integerValue];
        self.numberOfFollowing = [resultObjects[1] integerValue];
    }
                                                failBlock:^(NSOperation *operation, NSError *error)
    {
        self.numberOfFollowers = 0;
        self.numberOfFollowing = 0;
    }];
    
    if (_user.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue)
    {
        [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
        self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.editProfileButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        if ([VObjectManager sharedManager].mainUser)
        {
            self.editProfileButton.alpha = 0.0f;
            [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                         following:self.user
                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 self.editProfileButton.selected = [resultObjects[0] boolValue];
                 [UIView animateWithDuration:0.2f
                                  animations:^
                  {
                      self.editProfileButton.alpha = 1.0f;
                  }];
             }
                                         failBlock:nil];
        }
        else
        {
            self.editProfileButton.selected = NO;
        }
    }
}

- (void)setNumberOfFollowers:(NSInteger)numberOfFollowers
{
    _numberOfFollowers = numberOfFollowers;
    self.followersLabel.text = [[[VLargeNumberFormatter alloc] init] stringForInteger:numberOfFollowers];
}

- (void)setNumberOfFollowing:(NSInteger)numberOfFollowing
{
    _numberOfFollowing = numberOfFollowing;
    self.followingLabel.text = [[[VLargeNumberFormatter alloc] init] stringForInteger:numberOfFollowing];
}

- (IBAction)pressedEditProfile:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(editProfileHandler)])
    {
        [self.delegate editProfileHandler];
    }
}

- (IBAction)pressedFollowers:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followerHandler)])
    {
        [self.delegate followerHandler];
    }
}

- (IBAction)pressedFollowering:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followingHandler)])
    {
        [self.delegate followingHandler];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != VProfileHeaderContext)
    {
        return;
    }
    
    if (object == self.editProfileButton && [keyPath isEqualToString:@"selected"])
    {
        if (self.editProfileButton.selected)
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
            self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.editProfileButton.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
            self.editProfileButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
            self.editProfileButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        }
    }
}

@end
