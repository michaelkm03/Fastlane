//
//  VDependencyManager+VObjectManager.m
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VDependencyManager+VObjectManager.h"

NSString * const VDependencyManagerObjectManagerKey = @"objectManager";

@implementation VDependencyManager (VObjectManager)

- (VObjectManager *)objectManager
{
    return (VObjectManager *)[self templateValueOfType:[VObjectManager class] forKey:VDependencyManagerObjectManagerKey];
}

@end
