//
//  VTextToolController.m
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextToolController.h"
#import "VEditTextToolViewController.h"
#import "VCanvasView.h"
#import "VToolPicker.h"

@interface VTextToolController() <VToolPickerDelegate>

@end

@implementation VTextToolController

#pragma mark - VToolController overrides

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)setSelectedTool:(id<VWorkspaceTool>)selectedTool
{
    [super setSelectedTool:selectedTool];
    
    [self updateSelectedTool];
}

- (void)setupDefaultTool
{
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert( NO, @"Cannot set up default tool because there are no tools." );
    }
    
    [self setSelectedTool:self.tools.firstObject];
}

- (void)updateSelectedTool
{
    VEditTextToolViewController *editTextViewController = (VEditTextToolViewController *)self.selectedTool.canvasToolViewController;
    editTextViewController.text = self.text;
}

- (void)exportWithSourceAsset:(NSURL *)source withCompletion:(void (^)(BOOL, NSURL *, UIImage *, NSError *))completion
{
    completion( YES, nil, nil, nil );
}

- (void)setPickerDelegate:(id<VToolPickerDelegate>)delegate forSubtools:(NSArray *)subtools
{
    [subtools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         if ( [tool respondsToSelector:@selector(inspectorToolViewController)] &&
             tool.inspectorToolViewController != nil &&
             [tool.inspectorToolViewController conformsToProtocol:@protocol(VToolPicker)] )
         {
             id<VToolPicker> toolPicker = (id<VToolPicker>)tool.inspectorToolViewController;
             toolPicker.delegate = delegate;
         }
     }];
}

#pragma mark - VToolPickerDelegate

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index
{
    VEditTextToolViewController *editTextViewController = (VEditTextToolViewController *)self.selectedTool.canvasToolViewController;
    
    id selectedToolValue = [toolPicker.dataSource toolAtIndex:index];
    if ( [selectedToolValue isKindOfClass:[NSString class]] )
    {
        NSString *hashtag = (NSString *)selectedToolValue;
        editTextViewController.textPostViewController.supplementaryHashtagText = hashtag;
    }
    else if ( [selectedToolValue isKindOfClass:[UIColor class]] )
    {
        UIColor *color = (UIColor *)selectedToolValue;
        editTextViewController.textPostViewController.view.backgroundColor = color;
    }
}

@end
