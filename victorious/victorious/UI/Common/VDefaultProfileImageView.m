//
//  VDefaultProfileImageView.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileImageView.h"

// Utilities
#import "VThemeManager.h"
#import "VSettingManager.h"

// Categories
#import <SDWebImage/UIImageView+WebCache.h>

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
    self.image = [self defaultImage];
    
    NSString *colorKey = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kVLinkColor : kVAccentColor;
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:colorKey] colorWithAlphaComponent:.3f];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    self.clipsToBounds = YES;
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
}

- (void)setProfileImageURL:(NSURL *)url
{
    if ([self.sd_imageURL isEqual:url])
    {
        return;
    }
    [self sd_setImageWithURL:url
            placeholderImage:[self defaultImage]];
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:.3f];
}

- (UIImage *)defaultImage
{
    UIImage *image = [UIImage imageNamed:@"profile_thumb"];
    if (CGRectGetHeight(self.bounds) > image.size.height)
    {
        image = [UIImage imageNamed:@"profile_full"];
    }
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
