//
//  VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"

static NSString * const kIdentifierKey = @"identifier";
static NSString * const kDestinationKey = @"destination";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";

@implementation VNavigationMenuItem

- (instancetype)initWithTitle:(NSString *)title
                   identifier:(NSString *)identifier
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                  destination:(id)destination
{
    self = [super init];
    if (self)
    {
        _identifier = [identifier copy];
        _title = [title copy];
        _icon = icon;
        _selectedIcon = selectedIcon;
        _destination = destination;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *title = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    NSString *identifier = [dependencyManager stringForKey:kIdentifierKey];
    UIImage *icon = [dependencyManager imageForKey:kIconKey];
    UIImage *selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
    id destination = [dependencyManager singletonObjectOfType:[NSObject class] forKey:kDestinationKey];
    return [self initWithTitle:title identifier:identifier icon:icon selectedIcon:selectedIcon destination:destination];
}

- (BOOL)isEqual:(id)object
{
    VNavigationMenuItem *menuItem = object;
    
    if ( ![menuItem isKindOfClass:[VNavigationMenuItem class]] )
    {
        return NO;
    }
    return [self.title isEqualToString:menuItem.title] &&
        [self.icon isEqual:menuItem.icon] &&
        [self.destination isEqual:menuItem.destination] &&
        [self.identifier isEqual:menuItem.identifier];
}

@end
