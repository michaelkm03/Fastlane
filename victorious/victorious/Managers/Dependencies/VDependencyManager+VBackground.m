//
//  VDependencyManager+VBackground.m
//  victorious
//
//  Created by Michael Sena on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VBackground.h"
#import "VBackground.h"

static NSString * const kBackgroundKey = @"background";
static NSString * const kLoadingBackgroundKey = @"loadingBackground";

@implementation VDependencyManager (VBackground)

- (VBackground *)background
{
    return [self templateValueOfType:[VBackground class]
                              forKey:kBackgroundKey];
}

- (VBackground *)loadingBackground
{
    return [self templateValueOfType:[VBackground class]
                              forKey:kLoadingBackgroundKey];
}

@end
