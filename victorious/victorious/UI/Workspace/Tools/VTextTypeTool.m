//
//  VTextType.m
//  victorious
//
//  Created by Michael Sena on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTypeTool.h"
#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";

@interface VTextTypeTool ()

@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation VTextTypeTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
    }
    return self;
}

@end
