//
//  VWorkspaceToolController.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

@class VToolController;

@protocol VToolControllerDelegate <NSObject>

- (void)setCanvasViewController:(UIViewController *)canvasViewController;
- (void)setInspectorViewController:(UIViewController *)inspectorViewController;

@end

@interface VToolController : NSObject

- (instancetype)initWithTools:(NSArray /* NSArray of tools that conform to <VWorkspaceTool> */ *)tools;

- (void)exportToURL:(NSURL *)url
        sourceAsset:(NSURL *)source
     withCompletion:(void (^)(BOOL finished, UIImage *previewImage))completion;

@property (nonatomic, readonly) NSArray *tools;

@property (nonatomic, strong) id <VWorkspaceTool> selectedTool;

@property (nonatomic, strong) VCanvasView *canvasView;

@property (nonatomic, weak) id <VToolControllerDelegate> delegate;

@end
