//
//  VEndCard+Fetcher.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard+Fetcher.h"

@implementation VEndCard (Fetcher)

- (VSequencePermissions *)permissions
{
    return [VSequencePermissions permissionsWithNumber:self.permissionsMask];
}

@end
