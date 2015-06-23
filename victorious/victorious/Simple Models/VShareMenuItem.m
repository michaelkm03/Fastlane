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
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                    shareType:(VShareType)shareType
{
    self = [super init];
    if ( self != nil )
    {
        _title = title;
        _icon = icon;
        _selectedIcon = selectedIcon;
        _shareType = shareType;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *title = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    UIImage *icon = [dependencyManager tintedImageForKey:kDependencyManagerIconKey];
    UIImage *selectedIcon = [dependencyManager tintedImageForKey:kDependencyManagerSelectedIconKey];
    VShareType shareType = [self shareTypeFromString:[dependencyManager stringForKey:kDependencyManagerShareTypeKey]];
    return [self initWithTitle:title
                          icon:icon
                  selectedIcon:selectedIcon
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
