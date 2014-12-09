//
//  VFilterWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFilterWorkspaceTool.h"
#import "VToolPicker.h"
#import "VImageFilter.h"

#import "NSArray+VMap.h"
#import "VCanvasView.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

// Filters
#import "VPhotoFilterSerialization.h"

static NSString * const kTitleKey = @"title";
static NSString * const kPickerKey = @"picker";

@interface VFilterWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;

@end

@implementation VFilterWorkspaceTool

@synthesize canvasView = _canvasView;

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];

        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        
        NSURL *filters = [[NSBundle mainBundle] URLForResource:@"filters" withExtension:@"xml"];
        NSArray *rFilters = [VPhotoFilterSerialization filtersFromPlistFile:filters];
        NSArray *filterTools = [rFilters v_map:^id(VPhotoFilter *photoFilter)
        {
            VImageFilter *imageFilter = [[VImageFilter alloc] init];
            imageFilter.filter = photoFilter;
            return imageFilter;
        }];
        
        [(id<VToolPicker>)_toolPicker setTools:filterTools];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, title: %@, icon: %@", [super description], self.title, self.icon];
}

#pragma mark - VWorkspaceTool

- (void)setCanvasView:(VCanvasView *)canvasView
{
    _canvasView = canvasView;
    
    __weak typeof(self) welf = self;
    self.toolPicker.onToolSelection = ^void(VImageFilter <VWorkspaceTool> *selectedTool)
    {
        welf.canvasView.filter = selectedTool.filter;
    };
}

- (UIViewController *)inspectorToolViewController
{
    return (UIViewController *)self.toolPicker;
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
