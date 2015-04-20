//
//  VUserProfileHeaderViewController.m
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileHeaderViewController.h"

#import "VUser+Fetcher.h"

#import "VDependencyManager.h"
#import "VObjectManager+Users.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"
#import "VSettingManager.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"
#import "VDependencyManager+VUserProfile.h"

#import <KVOController/FBKVOController.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kEditButtonStyleKey = @"editButtonStyle";
static NSString * const kEditButtonStylePill = @"rounded";

@interface VUserProfileHeaderViewController()

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet VButton *editProfileButton;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *taglineLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersHeader;
@property (nonatomic, weak) IBOutlet UIButton *followersButton;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingHeader;
@property (nonatomic, weak) IBOutlet UIButton *followingButton;
@property (nonatomic, weak) IBOutlet UIView *userStatsBar;

@end

@implementation VUserProfileHeaderViewController

@synthesize delegate;
@synthesize isFollowingUser = _isFollowingUser;
@synthesize user = _user;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profileImageView.layer.borderWidth = 2.0;

    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");

    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];

    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    
    [self applyEditProfileButtonStyle];
    [self applyStyleWithDependencyManager:self.dependencyManager];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    [self applyEditProfileButtonStyle];
    
    self.user = [self.dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManagerUserKey];
}

- (void)loadBackgroundImage:(NSURL *)imageURL
{
    UIImage *placeholderImage = self.backgroundImageView.image;
    if ( placeholderImage == nil )
    {
        placeholderImage = [[UIImage resizeableImageWithColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]] applyLightEffect];
    }
    
    if ( ![self.backgroundImageView.sd_imageURL isEqual:imageURL] )
    {
        [self.backgroundImageView setBlurredImageWithURL:imageURL
                                        placeholderImage:placeholderImage
                                               tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    }
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setBlurredImageWithClearImage:[UIImage imageNamed:@"Default"]
                                           placeholderImage:nil
                                                  tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f]];
}

- (void)applyEditProfileButtonStyle
{
    if ( self.user == nil || self.dependencyManager == nil )
    {
        return;
    }
    
    const VUser *loggedInUser = [VObjectManager sharedManager].mainUser;
    const BOOL isCurrentUser = loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];

    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    if ( linkColor == nil )
    {
        linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    UIFont *buttonFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.editProfileButton.titleLabel.font = buttonFont;

    if ( [[self.dependencyManager stringForKey:kEditButtonStyleKey] isEqualToString:kEditButtonStylePill] )
    {
        self.editProfileButton.cornerRadius = CGRectGetHeight(self.editProfileButton.bounds) / 2.0f;
    }
    
    // Set the text
    if ( isCurrentUser )
    {
        [self.editProfileButton setStyle:VButtonStyleSecondary];
        self.editProfileButton.primaryColor = linkColor;
        self.editProfileButton.secondaryColor = linkColor;
        [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
    }
    else
    {
        if ( self.isFollowingUser )
        {
            [self.editProfileButton setStyle:VButtonStyleSecondary];
            self.editProfileButton.primaryColor = linkColor;
            self.editProfileButton.secondaryColor = linkColor;
            [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
        }
        else
        {
            [self.editProfileButton setStyle:VButtonStylePrimary];
            self.editProfileButton.primaryColor = linkColor;
            self.editProfileButton.secondaryColor = linkColor;
            [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Setters

- (void)setIsLoading:(BOOL)isLoading
{
    if ( isLoading )
    {
        [self.editProfileButton showActivityIndicator];
        self.editProfileButton.enabled = NO;
    }
    else
    {
        [self.editProfileButton hideActivityIndicator];
        self.editProfileButton.enabled = YES;
    }
}

- (void)setIsFollowingUser:(BOOL)isFollowingUser
{
    _isFollowingUser = isFollowingUser;
    [self applyEditProfileButtonStyle];
}

- (void)setUser:(VUser *)user
{
    _user = user;
        
    [self clearBackgroundImage];
    [self loadBackgroundImage:[NSURL URLWithString:self.user.pictureUrl]];
    
    [self reload];
}

- (void)reload
{
    [self applyEditProfileButtonStyle];
    
    if ( _user != nil )
    {
        [self cleanupKVOControllerWithUser:_user];
    }
    
    if ( self.user == nil )
    {
        [self applyEditProfileButtonStyle];
        return;
    }
    
    [self applyEditProfileButtonStyle];
    [self setupKVOControllerWithUser:_user];
    
    [[VObjectManager sharedManager] countOfFollowsForUser:_user
                                             successBlock:nil
                                                failBlock:nil];
    
    const BOOL isCurrentUser = [self.user.remoteId isEqualToNumber:[VObjectManager sharedManager].mainUser.remoteId];
    if ( isCurrentUser )
    {
        [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
    }
    else
    {
        __weak typeof(self) welf = self;
        if ([VObjectManager sharedManager].mainUser)
        {
            welf.editProfileButton.alpha = 0.0f;
            [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                         following:self.user
                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 welf.isFollowingUser = [resultObjects.firstObject boolValue];
                 [UIView animateWithDuration:0.2f
                                  animations:^
                  {
                      welf.editProfileButton.alpha = 1.0f;
                  }];
             }
                                         failBlock:nil];
        }
        else
        {
            welf.isFollowingUser = NO;
        }
    }
}

- (void)setFollowersCount:(NSNumber *)followerCount
{
    if ( followerCount != nil )
    {
        self.followersButton.hidden = NO;
        self.followersHeader.hidden = NO;
        self.followersLabel.hidden = NO;
        self.followersLabel.text = [self.largeNumberFormatter stringForInteger:followerCount.integerValue];
    }
    else
    {
        self.followersButton.hidden = YES;
        self.followersHeader.hidden = YES;
        self.followersLabel.hidden = YES;
    }
}

- (void)setFollowingCount:(NSNumber *)followingCount
{
    if ( followingCount != nil )
    {
        self.followingButton.hidden = NO;
        self.followingHeader.hidden = NO;
        self.followingLabel.hidden = NO;
        self.followingLabel.text = [self.largeNumberFormatter stringForInteger:followingCount.integerValue];
    }
    else
    {
        self.followingButton.hidden = YES;
        self.followingHeader.hidden = YES;
        self.followingLabel.hidden = YES;
    }
}

- (void)applyStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *accentColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    
    self.profileImageView.layer.borderColor = linkColor.CGColor;
    
    self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.locationLabel.font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    
    self.taglineLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.taglineLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.followersLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = accentColor;
    
    self.followersHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = accentColor;
    
    self.followingLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = accentColor;
    
    self.followingHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = accentColor;
    
    UIColor *backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.userStatsBar.backgroundColor = backgroundColor;
    [self applyEditProfileButtonStyle];
}

#pragma mark - Actions

- (IBAction)pressedEditProfile:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(editProfileHandler)])
    {
        [self.delegate editProfileHandler];
    }
}

- (IBAction)pressedFollowers:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowers];
    
    if ([self.delegate respondsToSelector:@selector(followerHandler)])
    {
        [self.delegate followerHandler];
    }
}

- (IBAction)pressedFollowering:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowing];
    
    if ([self.delegate respondsToSelector:@selector(followingHandler)])
    {
        [self.delegate followingHandler];
    }
}

#pragma mark - KVOController for properties of VUser

- (void)cleanupKVOControllerWithUser:(VUser *)user
{
    [self.KVOController unobserve:user];
}

- (void)setupKVOControllerWithUser:(VUser *)user
{
    __weak typeof(self) welf = self;
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(numberOfFollowers))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf setFollowersCount:user.numberOfFollowers];
     }];
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(numberOfFollowing))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf setFollowingCount:user.numberOfFollowing];
     }];
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(pictureUrl))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf.profileImageView setProfileImageURL:[NSURL URLWithString:user.pictureUrl]];
     }];
    
    [self.KVOController observe:user
                       keyPaths:@[ NSStringFromSelector(@selector(name)),
                                   NSStringFromSelector(@selector(tagline)),
                                   NSStringFromSelector(@selector(location)) ]
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf reloadObservedProfileProperties];
     }];
}

- (void)reloadObservedProfileProperties
{
    [self applyEditProfileButtonStyle];
    
    //Set a minimum line height by setting an NSParagraphStyle to properly display emojis without cutting them off
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = self.nameLabel.font.lineHeight + 2.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSString *safeName = self.user.name != nil ? self.user.name : @"";
    NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraphStyle };
    self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:safeName
                                                                    attributes:attributes];
    self.locationLabel.text = self.user.location;
    
    if ( self.user.tagline != nil && self.user.tagline.length > 0 )
    {
        self.taglineLabel.text = self.user.tagline;
    }
    else
    {
        self.taglineLabel.text = @"";
    }
}

@end
