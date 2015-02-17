//
//  VInlineUserTableViewCell.m
//  victorious
//
//  Created by Lawrence Leach on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineUserTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VThemeManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation VInlineUserTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileName.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];

    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self setPreservesSuperviewLayoutMargins:NO];
    [self setSeparatorInset:UIEdgeInsetsZero];
    [self setLayoutMargins:UIEdgeInsetsZero];
    
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    // Set Profile Image
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString: profile.pictureUrl]
                         placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileImage.layer.cornerRadius = CGRectGetHeight(self.profileImage.bounds)/2;
    self.profileImage.layer.borderWidth = 1.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
    
    // Set Profile Name
    self.profileName.text = profile.name;
}

@end
