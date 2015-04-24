//
//  VActionBarFlexibleSpaceItem.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionBarFlexibleSpaceItem.h"

@implementation VActionBarFlexibleSpaceItem

+ (VActionBarFlexibleSpaceItem *)flexibleSpaceItem
{
    VActionBarFlexibleSpaceItem *flexibleSpaceItem = [[VActionBarFlexibleSpaceItem alloc] initWithFrame:CGRectZero];
    flexibleSpaceItem.translatesAutoresizingMaskIntoConstraints = NO;
    return flexibleSpaceItem;
}

@end
