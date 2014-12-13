//
//  VMemeWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMemeTool.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"
#import "VTextToolViewController.h"

static NSString * const kTitleKey = @"title";

@interface VMemeTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) VTextToolViewController *toolViewController;

@end

@implementation VMemeTool

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _toolViewController = [VTextToolViewController memeToolViewController];
    }
    return self;
}

#pragma mark - VWorkspaceTool

- (UIViewController *)canvasToolViewController
{
    return _toolViewController;
}

@end
