//
//  VLoginWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithSocialViewController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"

@interface VProfileWithSocialViewController ()
@property (nonatomic, weak) IBOutlet    UITextField*    nameTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    locationTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    usernameTextField;
@property (nonatomic, weak) IBOutlet    UITextView*     taglineTextView;
@property (nonatomic, weak) IBOutlet    UIImageView*    profileImageView;
@property (nonatomic, weak) IBOutlet    UIButton*       headerButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       agreeSwitch;
@end

@implementation VProfileWithSocialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

//- (void)setupHeader
//{
    // Create and set the header
//    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
//    [self.profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
//    self.profileImageView.layer.masksToBounds = YES;
//    self.profileImageView.layer.cornerRadius = 50.0;
//    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    self.profileImageView.layer.shouldRasterize = YES;
//    self.profileImageView.clipsToBounds = YES;
//    
//    self.headerButton.layer.masksToBounds = YES;
//    self.headerButton.layer.cornerRadius = 50.0;
//    self.headerButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    self.headerButton.layer.shouldRasterize = YES;
//    self.headerButton.clipsToBounds = YES;
//    
//    self.usernameLabel.text = self.profile.shortName;
//}
//
//- (void)setupProfile
//{
//    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
//    backgroundImageView.image = [[UIImage imageNamed:@"profile_full"] applyLightEffect];
//    self.tableView.backgroundView = backgroundImageView;
//
//    self.nameLabel.text = self.profile.name;
//    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.username"];
//    self.taglineLabel.text = [NSString stringWithFormat:@"“%@”",self.profile.tagline];
//    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.tagline"];
//    self.locationLabel.text = self.profile.location;
//    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.profile.location"];
//}

@end
