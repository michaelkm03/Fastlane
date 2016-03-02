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
#import "VHashtagPickerDataSource.h"
#import "VEditableTextPostViewController.h"
#import "VTextPostImageHelper.h"
#import "victorious-Swift.h"

@interface VTextToolController() <VMultipleToolPickerDelegate, VEditableTextPostViewControllerDelegate>

@property (nonatomic, weak) VHashtagTool<VWorkspaceTool> *hashtagTool;
@property (nonatomic, strong) VTextPostImageHelper *imageHelper;
@property (nonatomic, weak, readwrite) VTextColorTool<VWorkspaceTool> *textColorTool;
@property (nonatomic, strong, readwrite) UIImage *previewImage;

@end

@implementation VTextToolController

#pragma mark - VToolController overrides

@synthesize mediaURL;  ///< VToolController

- (void)setupDefaultTool
{
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert( NO, @"Cannot set up default tool because there are no tools." );
    }
    
    if ( self.selectedTool == nil )
    {
        [self setSelectedTool:self.tools.firstObject];
    }
    
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
    
    // If there is a background image and color, they must be rendered together into the final tinted output image
    if ( self.mediaURL != nil && [self currentColorSelection] != nil )
    {
        self.imageHelper = [[VTextPostImageHelper alloc] init];
        [self.imageHelper exportWithAssetAtURL:self.mediaURL color:[self currentColorSelection] completion:^(NSURL *renderedAssetURL, NSError *error )
         {
             if ( renderedAssetURL != nil )
             {
                 [self publishTextPost:renderedAssetURL completion:completion];
             }
             else
             {
                 completion( NO, nil, nil, error );
             }
         }];
    }
    else
    {
        // If there is no background image selector or there is no color, then skip ahead to publish
        [self publishTextPost:self.mediaURL completion:completion];
    }
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
        self.textPostViewController.color = colorType.color;
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

- (void)setMediaURL:(NSURL *)newMediaURL previewImage:(UIImage *)previewImage
{
    self.previewImage = previewImage;
    self.mediaURL = newMediaURL;
    [self.textColorTool setShouldShowNoColorOption:(previewImage != nil) completion:^
    {
        [self.textPostViewController setBackgroundImage:previewImage animated:YES];
    }];
    
}

@end
