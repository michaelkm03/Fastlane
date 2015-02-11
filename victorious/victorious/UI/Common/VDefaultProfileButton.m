//
//  VDefaultProfileButton.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileButton.h"

#import "VThemeManager.h"

#import <SDWebImage/UIButton+WebCache.h>
#import "VSettingManager.h"

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
    NSString *colorKey = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kVLinkColor : kVAccentColor;
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:colorKey] colorWithAlphaComponent:.3f];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];

}

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    
    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self sd_setImageWithURL:url
                    forState:controlState
            placeholderImage:defaultImage];
    
    self.imageView.tintColor = self.tintColor;
}

@end
