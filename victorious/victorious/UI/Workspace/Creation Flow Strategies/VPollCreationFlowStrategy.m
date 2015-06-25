//
//  VPollCreationFlowStrategy.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollCreationFlowStrategy.h"

@interface VPollCreationFlowStrategy ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VPollCreationFlowStrategy

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

@end
