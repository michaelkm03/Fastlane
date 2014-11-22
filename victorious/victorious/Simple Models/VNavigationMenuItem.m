//
//  VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationMenuItem.h"

@implementation VNavigationMenuItem

- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier icon:(UIImage *)icon destination:(id)destination
{
    self = [super init];
    if (self)
    {
        _identifier = [identifier copy];
        _title = [title copy];
        _icon = icon;
        _destination = destination;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    VNavigationMenuItem *menuItem = object;
    
    if ( ![menuItem isKindOfClass:[VNavigationMenuItem class]])
    {
        return NO;
    }
    return [self.title isEqualToString:menuItem.title] && [self.icon isEqual:menuItem.icon] && [self.destination isEqual:menuItem.destination];
}

@end
