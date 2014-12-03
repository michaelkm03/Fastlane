//
//  VFilterWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFilterWorkspaceTool.h"

#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";

@interface VFilterWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end

@implementation VFilterWorkspaceTool

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
    }
    return self;
}

#pragma mark - VWorkspaceTool

- (NSString *)title
{
    return _title;
}

- (UIImage *)icon
{
    return _icon;
}

@end
