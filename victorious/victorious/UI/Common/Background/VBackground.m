//
//  VBackground.m
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBackground.h"

@implementation VBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    return self;
}

- (UIView *)viewForBackground
{
    NSAssert(false, @"Must be implemented by subclasses!");
    return nil;
}

@end
