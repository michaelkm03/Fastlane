//
//  VUser+Fetcher.m
//  victorious
//
//  Created by Will Long on 5/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser+Fetcher.h"
#import "VConstants.h"

@implementation VUser (Fetcher)

- (BOOL)isOwner
{
    return [self.accessLevel isEqualToString:kOwnerAccessLevel];
}

@end
