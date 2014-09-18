//
//  VTableViewCell.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"
#import "VThemeManager.h"

@implementation VTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[UIImageView appearanceWhenContainedIn:[self class], nil]
     setTintColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor]];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop)
     {
         imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
     }];
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
         label.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
     }];
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop)
     {
         button.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
         button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
     }];
}

@end
