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
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self setImage:defaultImage forState:UIControlStateNormal];
    
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:.3f];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];

}

- (void)setUser:(VUser *)user
{
    _user = user;

    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self setImageWithURL:[NSURL URLWithString:user.pictureUrl]
          placeholderImage:defaultImage
                  forState:UIControlStateNormal];
    
    self.imageView.tintColor = self.tintColor;
}

@end
