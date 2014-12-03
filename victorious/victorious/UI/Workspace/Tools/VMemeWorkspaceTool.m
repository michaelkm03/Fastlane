//
//  VMemeWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMemeWorkspaceTool.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

static NSString * const kTitleKey = @"title";

@interface VMemeWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end

@implementation VMemeWorkspaceTool

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
