//
//  VDefaultProfileImageView.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileImageView.h"

#import "VThemeManager.h"
#import "VUser.h"

@implementation VDefaultProfileImageView

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
    self.image = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:.3f];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
}

- (void)setImageWithUser:(VUser *)user
{
    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImageWithURL:[NSURL URLWithString:user.pictureUrl] placeholderImage:defaultImage];
}

@end
