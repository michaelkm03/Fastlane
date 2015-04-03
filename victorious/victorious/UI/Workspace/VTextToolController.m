//
//  VTextToolController.m
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextToolController.h"
#import "VTextCanvasToolViewController.h"
#import "VCanvasView.h"
#import "VToolPicker.h"
#import "VHashtagType.h"
#import "VColorType.h"
#import "VTextColorTool.h"
#import "VHashtagTool.h"
#import "VObjectManager+ContentCreation.h"
#import "VHashtagPickerDataSource.h"
#import "VEditableTextPostViewController.h"

@interface VTextToolController() <VMultipleToolPickerDelegate, VEditableTextPostViewControllerDelegate>

@property (nonatomic, weak) VTextColorTool<VWorkspaceTool> *textColorTool;
@property (nonatomic, weak) VHashtagTool<VWorkspaceTool> *hashtagTool;
@property (nonatomic, readonly, weak) VEditableTextPostViewController *textPostViewController;

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

- (void)setupDefaultTool
{
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert( NO, @"Cannot set up default tool because there are no tools." );
    }
    
    [self setSelectedTool:self.tools.firstObject];
    
    [self.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         if ( [tool isKindOfClass:[VTextColorTool class]] )
         {
             id<VToolPicker> toolPicker = (id<VToolPicker>)tool.inspectorToolViewController;
             toolPicker.pickerDelegate = self;
             self.textColorTool = tool;
             [self toolPicker:toolPicker didSelectTool:toolPicker.selectedTool]; //< Select first color
         }
         else if ( [tool isKindOfClass:[VHashtagTool class]] )
         {
             id<VMultipleToolPicker> toolPicker = (id<VMultipleToolPicker>)tool.inspectorToolViewController;
             toolPicker.multiplePickerDelegate = self;
             self.hashtagTool = tool;
         }
     }];
    
    self.textPostViewController.delegate = self;
}

- (void)exportWithSourceAsset:(NSURL *)source withCompletion:(void (^)(BOOL, NSURL *, UIImage *, NSError *))completion
{
    self.textPostViewController.isEditing = NO;
    
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
    return self.textPostViewController.text;
}

- (VTextPostViewController *)textPostViewController
{
    VTextCanvasToolViewController *editTextViewController = (VTextCanvasToolViewController *)self.selectedTool.canvasToolViewController;
    return editTextViewController.textPostViewController;
}

- (BOOL)canPublish
{
    return self.textPostViewController.textOutput.length > 0;
}

#pragma mark - VToolPickerDelegate

- (void)toolPicker:(id<VCollectionToolPicker>)toolPicker didSelectTool:(id<VWorkspaceTool>)tool
{
    if ( [tool isKindOfClass:[VColorType class]] )
    {
        VColorType *colorType = (VColorType *)tool;
        self.textPostViewController.view.backgroundColor = colorType.color;
    }
}

#pragma mark - VMultipleToolPickerDelegate

- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index
{
    id selectedTool = ((id<VCollectionToolPicker>) toolPicker).dataSource.tools[ index ];
    if ( [selectedTool isKindOfClass:[VHashtagType class]] )
    {
        VHashtagType *hashtagType = (VHashtagType *)selectedTool;
        BOOL selectionSucceeded = [self.textPostViewController addHashtag:hashtagType.hashtagText];
        if ( !selectionSucceeded )
        {
            [toolPicker deselectToolAtIndex:index];
        }
    }
}

- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didDeselectItemAtIndex:(NSInteger)index
{
    id selectedTool = ((id<VCollectionToolPicker>) toolPicker).dataSource.tools[ index ];
    if ( [selectedTool isKindOfClass:[VHashtagType class]] )
    {
        VHashtagType *hashtagType = (VHashtagType *)selectedTool;
        [self.textPostViewController removeHashtag:hashtagType.hashtagText];
    }
}

#pragma mark - VEditableTextPostViewControllerDelegate

- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags
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

- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didAddHashtags:(NSArray *)addedHashtags
{
    VHashtagPickerDataSource *dataSource = self.hashtagTool.toolPicker.dataSource;
    [addedHashtags enumerateObjectsUsingBlock:^(NSString *hashtag, NSUInteger idx, BOOL *stop)
     {
         id<VWorkspaceTool> tool = [dataSource toolForHashtag:hashtag];
         if ( tool != nil )
         {
             NSInteger index = [dataSource.tools indexOfObject:tool];
             [self.hashtagTool.toolPicker selectToolAtIndex:index];
         }
     }];
}

- (void)textDidUpdate:(NSString *)text
{
    [self.textListener textDidUpdate:text];
}

@end
