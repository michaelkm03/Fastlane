//
//  VFilterWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFilterWorkspaceTool.h"
#import "VToolPicker.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";

@interface VFilterWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIViewController *toolPicker;
@property (nonatomic, strong) NSArray *subtools;

@end

@implementation VFilterWorkspaceTool

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _subtools = [dependencyManager tools];
        _toolPicker = [dependencyManager viewControllerForKey:kPickerKey];
        [(id<VToolPicker>)_toolPicker setTools:_subtools];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, title: %@, icon: %@", [super description], self.title, self.icon];
}

#pragma mark - VWorkspaceTool

- (UIViewController *)canvasToolViewController
{
    return nil;
}

- (UIViewController *)inspectorToolViewController
{
    return self.toolPicker;
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
