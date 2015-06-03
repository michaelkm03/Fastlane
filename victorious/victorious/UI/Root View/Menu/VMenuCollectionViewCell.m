//
//  VMenuCollectionViewCell.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAutomation.h"
#import "VNumericalBadgeView.h"
#import "VDependencyManager.h"
#import "VMenuCollectionViewCell.h"
#import "VNavigationMenuItem.h"

static const CGFloat kCellHeight = 50.0f;

@interface VMenuCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *menuLabel; ///< A label to hold the menu item (e.g. "Home", "Channel", etc.)
@property (nonatomic, weak) IBOutlet VNumericalBadgeView *badgeView; ///< A label to hold a badge number (typically for the inbox menu item)

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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ( dependencyManager != nil )
    {
        self.menuLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        self.menuLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        self.badgeView.font = [dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    }
}

- (void)prepareForReuse
{
    self.menuLabel.text = @"";
    [self setBadgeNumber:0];
    self.accessibilityIdentifier = nil;
}

#pragma mark - VNavigationMenuItemCell methods

- (void)setNavigationMenuItem:(VNavigationMenuItem *)navigationMenuItem
{
    self.menuLabel.text = navigationMenuItem.title;
    self.accessibilityIdentifier = navigationMenuItem.identifier;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    [self.badgeView setBadgeNumber:badgeNumber];
}

@end
