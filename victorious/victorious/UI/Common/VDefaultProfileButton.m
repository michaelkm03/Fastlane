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
    
    //Was previously accent color for A and D
    NSString *colorKey = kVLinkColor;
    self.tintColor = [[[VThemeManager sharedThemeManager] themedColorForKey:colorKey] colorWithAlphaComponent:.3f];
    
    [self updateCornerRadius];
    self.clipsToBounds = YES;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];

}

- (void)updateCornerRadius
{
    CGFloat radius = ( CGRectGetHeight(self.bounds) - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom )/2 ;
    self.layer.cornerRadius = radius;
}

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    
    UIImage *defaultImage = [[UIImage imageNamed:@"profile_thumb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self sd_setImageWithURL:url
                    forState:controlState
            placeholderImage:defaultImage];
    
    self.imageView.tintColor = self.tintColor;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateCornerRadius];
}

@end
