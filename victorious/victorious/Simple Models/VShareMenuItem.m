//
//  VShareMenuItem.m
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShareMenuItem.h"
#import "VDependencyManager.h"

static NSString * const kDependencyManagerIconKey = @"icon";
static NSString * const kDependencyManagerSelectedIconKey = @"selectedIcon";
static NSString * const kDependencyManagerShareTypeKey = @"shareType";

@implementation VShareMenuItem

- (instancetype)initWithTitle:(NSString *)title
               unselectedIcon:(UIImage *)unselectedIcon
                 selectedIcon:(UIImage *)selectedIcon
              unselectedColor:(UIColor *)unselectedColor
                selectedColor:(UIColor *)selectedColor
                    shareType:(VShareType)shareType
{
    self = [super init];
    if ( self != nil )
    {
        _title = title;
        _unselectedIcon = unselectedIcon;
        _selectedIcon = selectedIcon;
        _unselectedColor = unselectedColor;
        _selectedColor = selectedColor;
        _shareType = shareType;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *title = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    UIImage *unselectedIcon = [dependencyManager imageForKey:kDependencyManagerIconKey];
    UIImage *selectedIcon = [dependencyManager imageForKey:kDependencyManagerSelectedIconKey];
    UIColor *unselectedColor = [dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    UIColor *selectedColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    VShareType shareType = [self shareTypeFromString:[dependencyManager stringForKey:kDependencyManagerShareTypeKey]];
    return [self initWithTitle:title
                unselectedIcon:unselectedIcon
                  selectedIcon:selectedIcon
               unselectedColor:unselectedColor
                 selectedColor:selectedColor
                     shareType:shareType];
}

- (VShareType)shareTypeFromString:(NSString *)string
{
    VShareType shareType = VShareTypeUnknown;
    if ( [string isEqualToString:@"facebook"] )
    {
        shareType = VShareTypeFacebook;
    }
    else if ( [string isEqualToString:@"twitter"] )
    {
        shareType = VShareTypeTwitter;
    }
    return shareType;
}

@end
