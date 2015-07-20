//
//  VUser+Fetcher.m
//  victorious
//
//  Created by Michael Sena on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUser+Fetcher.h"

@implementation VUser (Fetcher)

- (BOOL)shouldSkipTrimmer
{
    NSInteger trimmerDuration = [self.maxVideoDuration integerValue];
    return (trimmerDuration > 15);
}

@end
