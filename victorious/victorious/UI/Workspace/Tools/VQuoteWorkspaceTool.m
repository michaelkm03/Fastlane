//
//  VQuoteWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VQuoteWorkspaceTool.h"

#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";

@interface VQuoteWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end

@implementation VQuoteWorkspaceTool

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

- (UIViewController *)canvasToolViewController
{
#warning Implement ME
    return nil;
}

- (UIViewController *)inspectorToolViewController
{
    return nil;
}

- (NSString *)title
{
    return _title;
}

- (UIImage *)icon
{
    return _icon;
}

@end
