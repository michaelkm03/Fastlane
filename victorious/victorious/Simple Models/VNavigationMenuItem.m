//
//  VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIdentifierKey = @"identifier";
static NSString * const kDestinationKey = @"destination";

@implementation VNavigationMenuItem

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _identifier = [dependencyManager stringForKey:kIdentifierKey];
        _title = [dependencyManager stringForKey:kTitleKey];
        _icon = nil;
        _destination = [dependencyManager singletonObjectOfType:[NSObject class] forKey:kDestinationKey];
    }
    return self;
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
