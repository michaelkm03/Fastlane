//
//  VCategoryWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCategoryWorkspaceTool.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"
#import "VToolPicker.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";

@interface VCategoryWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSArray *subTools;

@property (nonatomic, strong, readwrite) UIViewController  *toolPicker;

@end

@implementation VCategoryWorkspaceTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _subTools = [dependencyManager tools];
        _toolPicker = [dependencyManager viewControllerForKey:kPickerKey];
        [(id<VToolPicker>)_toolPicker setTools:_subTools];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, title: %@, icon: %@, subtools: %@]", [super description], self.title, self.icon, self.subTools];
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

#pragma mark - Property Accessors

- (NSArray *)subTools
{
    return _subTools;
}

- (UIViewController *)toolPicker
{
    return _toolPicker;
}

@end
