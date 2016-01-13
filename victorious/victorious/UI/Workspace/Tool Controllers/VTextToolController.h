//
//  VTextToolController.h
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"
#import "VTextListener.h"

@class VDependencyManager, VTextToolController, VEditableTextPostViewController, VTextColorTool;
@protocol VWorkspaceTool;

/**
 A VToolController that handles creating text posts within the workspace.
 */
@interface VTextToolController : VToolController

/**
 *  The default text tool.
 */
@property (nonatomic, assign) NSUInteger defaultTool;

/**
 Indicates whether the text post being created in its current state
 meets all requirements to be published.
 */
@property (nonatomic, readonly) BOOL canPublish;

/**
 Set this to YES if this text post is to be published
 via a forced content creation screen.
 */
@property (nonatomic, assign) BOOL publishIsForced;

/**
 An object that can receive updates when the text post is edited.
 */
@property (nonatomic, weak) id<VTextListener> textListener;

@property (nonatomic, readonly, weak) VEditableTextPostViewController *textPostViewController;

@property (nonatomic, readonly, weak) VTextColorTool<VWorkspaceTool> *textColorTool;

- (void)setMediaURL:(NSURL *)newMediaURL previewImage:(UIImage *)previewImage;

@end
