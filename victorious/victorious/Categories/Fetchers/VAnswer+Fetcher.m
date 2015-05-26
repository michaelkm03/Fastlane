//
//  VAnswer+Fetcher.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAnswer+Fetcher.h"

@implementation VAnswer (Fetcher)

- (NSURL *)previewMediaURL
{
    return [NSURL URLWithString:self.thumbnailUrl];
}

@end
