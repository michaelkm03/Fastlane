//
//  VAsset+VFetcher.m
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAsset+Fetcher.h"

@implementation VAsset (Fetcher)

- (NSURL *)dataURL
{
    return [NSURL URLWithString:self.data];
}

@end
