//
//  VEndCard+Fetcher.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard+Fetcher.h"

@implementation VEndCard (Fetcher)

- (VPermissions *)permissions
{
    return [VPermissions permissionsWithNumber:self.permissionsMask];
}

@end
