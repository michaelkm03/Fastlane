//
//  VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"
#import "victorious-Swift.h"

NSString * const VDependencyManagerPositionKey      = @"position";
NSString * const VDependencyManagerDestinationKey   = @"destination";
NSString * const VDependencyManagerIdentifierKey    = @"identifier";
NSString * const VDependencyManagerIconKey          = @"icon";
NSString * const VDependencyManagerSelectedIconKey  = @"selectedIcon";
NSString * const VDependencyManagerPositionLeft     = @"left";
NSString * const VDependencyManagerPositionRight    = @"right";

@interface VNavigationMenuItem()

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@end

@implementation VNavigationMenuItem

- (instancetype)initWithTitle:(NSString *)title
                   identifier:(NSString *)identifier
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                  destination:(id)destination
                     position:(NSString *)position
                    tintColor:(UIColor *)tintColor
{
    self = [super init];
    if (self)
    {
        _identifier = [identifier copy];
        _title = [title copy];
        _icon = icon;
        _selectedIcon = selectedIcon;
        _destination = destination;
        _tintColor = tintColor;
        _position = position;
    }
    return self;
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *title = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    NSString *identifier = [dependencyManager stringForKey:VDependencyManagerIdentifierKey];
    UIImage *icon = [dependencyManager imageForKey:VDependencyManagerIconKey];
    UIImage *selectedIcon = [dependencyManager imageForKey:VDependencyManagerSelectedIconKey];
    id destination = [dependencyManager singletonObjectOfType:[NSObject class] forKey:VDependencyManagerDestinationKey];
    NSString *position = [dependencyManager stringForKey:VDependencyManagerPositionKey];
    UIColor *tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    VNavigationMenuItem *menuItem = [self initWithTitle:title
                                             identifier:identifier
                                                   icon:icon
                                           selectedIcon:selectedIcon
                                            destination:destination
                                               position:position
                                              tintColor:tintColor];
    menuItem.dependencyManager = dependencyManager;
    return menuItem;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (BOOL)isEqual:(id)object
{
    if ( [object isKindOfClass:[VNavigationMenuItem class]] )
    {
        VNavigationMenuItem *menuItem = object;
        return [self.identifier isEqualToString:menuItem.identifier];
    }
    
    return [super isEqual:object];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@ (%@)", NSStringFromClass([self class]), self.identifier, self.position];
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (BOOL)hasValidDestination
{
    return self.description != nil && ![self.destination isKindOfClass:[NSNull class]];
}

@end
