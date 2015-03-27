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
#import "VHashtagType.h"
#import "VColorType.h"
#import "VTextColorTool.h"
#import "VHashtagTool.h"
#import "VObjectManager+ContentCreation.h"
#import "VHashtagPickerDataSource.h"

@interface VTextToolController() <VToolPickerDelegate, VTextPostViewControllerDelegate>

@property (nonatomic, weak) VTextColorTool<VWorkspaceTool> *textColorTool;
@property (nonatomic, weak) VHashtagTool<VWorkspaceTool> *hashtagTool;
@property (nonatomic, readonly, weak) VTextPostViewController *textPostViewController;

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
}

- (void)setupDefaultTool
{
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert( NO, @"Cannot set up default tool because there are no tools." );
    }
    
    [self setPickerDelegate:self forSubtools:self.tools];
    
    [self setSelectedTool:self.tools.firstObject];
    
    [self.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         id<VToolPicker> toolPicker = (id<VToolPicker>)tool.inspectorToolViewController;
         if ( [tool isKindOfClass:[VTextColorTool class]] )
         {
             self.textColorTool = tool;
         }
         else if ( [tool isKindOfClass:[VHashtagTool class]] )
         {
             self.hashtagTool = tool;
         }
         [self toolPicker:toolPicker didSelectItemAtIndex:0];
     }];
    
    self.textPostViewController.delegate = self;
}

- (void)exportWithSourceAsset:(NSURL *)source withCompletion:(void (^)(BOOL, NSURL *, UIImage *, NSError *))completion
{
    [[VObjectManager sharedManager] createTextPostWithText:[self currentText]
                                           backgroundColor:[self currentColorSelection]
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         
         completion( YES, nil, nil, nil );
     }
                                                 failBlock:^(NSOperation *operation, NSError *error)
     {
         NSLog( @"error posting text: %@", [error localizedDescription] );
         completion( YES, nil, nil, nil );
     }];
}

- (UIColor *)currentColorSelection
{
    id<VToolPicker> colorPicker = (id<VToolPicker>)self.textColorTool.toolPicker;
    VColorType *selectedTool = (VColorType *)colorPicker.selectedTool;
    return selectedTool.color;
}

- (NSString *)currentText
{
    VEditTextToolViewController *editTextViewController = (VEditTextToolViewController *)self.selectedTool.canvasToolViewController;
    return editTextViewController.textPostViewController.text;
}

- (void)setPickerDelegate:(id<VToolPickerDelegate>)delegate forSubtools:(NSArray *)subtools
{
    [subtools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         id<VToolPicker> toolPicker = (id<VToolPicker>)tool.inspectorToolViewController;
         toolPicker.delegate = delegate;
     }];
}

- (VTextPostViewController *)textPostViewController
{
    VEditTextToolViewController *editTextViewController = (VEditTextToolViewController *)self.selectedTool.canvasToolViewController;
    return editTextViewController.textPostViewController;
}

#pragma mark - VToolPickerDelegate

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index
{
    id selectedTool = toolPicker.dataSource.tools[ index ];
    if ( [selectedTool isKindOfClass:[VHashtagType class]] )
    {
        VHashtagType *hashtagType = (VHashtagType *)selectedTool;
        [self.textPostViewController addHashtag:hashtagType.hashtagText];
    }
    else if ( [selectedTool isKindOfClass:[VColorType class]] )
    {
        VColorType *colorType = (VColorType *)selectedTool;
        self.textPostViewController.view.backgroundColor = colorType.color;
    }
}

- (void)toolPicker:(id<VToolPicker>)toolPicker didDeselectItemAtIndex:(NSInteger)index
{
    id selectedTool = toolPicker.dataSource.tools[ index ];
    if ( [selectedTool isKindOfClass:[VHashtagType class]] )
    {
        VHashtagType *hashtagType = (VHashtagType *)selectedTool;
        [self.textPostViewController removeHashtag:hashtagType.hashtagText];
    }
}

#pragma mark - VTextPostViewControllerDelegate

- (void)textPostViewController:(VTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags
{
    VHashtagPickerDataSource *dataSource = self.hashtagTool.toolPicker.dataSource;
    [deletedHashtags enumerateObjectsUsingBlock:^(NSString *hashtag, NSUInteger idx, BOOL *stop)
    {
        id<VWorkspaceTool> tool = [dataSource toolForHashtag:hashtag];
        if ( tool != nil )
        {
            NSInteger index = [dataSource.tools indexOfObject:tool];
            [self.hashtagTool.toolPicker deselectToolAtIndex:index];
        }
    }];
}

@end
