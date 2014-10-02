//
//  VDefaultProfileButton.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileButton.h"

#import "VThemeManager.h"
#import "VUser.h"

#import "UIButton+VImageLoading.h"

@implementation VDefaultProfileButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageView = [[VDefaultProfileImageView alloc] initWithFrame:self.bounds];
}

- (void)setProfileImageView:(VDefaultProfileImageView *)profileImageView
{
    [_profileImageView removeFromSuperview];
    _profileImageView = profileImageView;
    [self addSubview:_profileImageView];
}

- (void)setUser:(VUser *)user
{
    _user = user;
    self.profileImageView.user = user;
}

@end
