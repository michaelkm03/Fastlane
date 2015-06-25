//
//  VGIFCreationFlowStrategy.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFCreationFlowStrategy.h"

@interface VGIFCreationFlowStrategy ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VGIFCreationFlowStrategy

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
