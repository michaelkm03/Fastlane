//
//  VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationMenuItem.h"

@implementation VNavigationMenuItem

- (instancetype)initWithLabel:(NSString *)label icon:(UIImage *)icon destination:(UIViewController *)destination
{
    self = [super init];
    if (self)
    {
        _label = [label copy];
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
    return [self.label isEqualToString:menuItem.label] && [self.icon isEqual:menuItem.icon] && [self.destination isEqual:menuItem.destination];
}

@end
