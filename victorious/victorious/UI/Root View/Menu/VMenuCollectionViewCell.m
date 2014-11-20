//
//  VMenuCollectionViewCell.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMenuCollectionViewCell.h"
#import "VNavigationMenuItem.h"
#import "VThemeManager.h"
#import "VAccessibilityConstants.h"

static const CGFloat kCellHeight = 50.0f;

@interface VMenuCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *menuLabel; ///< A label to hold the menu item (e.g. "Home", "Channel", etc.)
@property (nonatomic, weak) IBOutlet UILabel *badgeLabel; ///< A label to hold a badge number (typically for the inbox menu item)

@end

@implementation VMenuCollectionViewCell

+ (UINib *)nibForCell
{
    NSAssert(NO, @"Unsupported");
    return nil;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kCellHeight);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIFont *font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.menuLabel.font = [font fontWithSize:22.0];
    self.menuLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];

    self.badgeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.badgeLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.badgeLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
}

- (void)setNavigationMenuItem:(VNavigationMenuItem *)navigationMenuItem
{
    self.menuLabel.text = navigationMenuItem.title;
    self.accessibilityIdentifier = [NSString stringWithFormat:kVAccessibilityIdMainMenuItem, navigationMenuItem.title];
}

- (void)prepareForReuse
{
    self.menuLabel.text = @"";
    self.badgeLabel.text = @"";
    self.accessibilityIdentifier = nil;
}

@end
