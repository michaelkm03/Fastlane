//
//  VWorkspaceToolController.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

@class VToolController;

/**
 *  A delegate for notifying the workspace about new canvas / inspector view controllers.
 */
@protocol VToolControllerDelegate <NSObject>

/**
 *  Notifies the delegate when a new canvas view controller should be added. This should NOT automatically remove old canvas view controllers.
 */
- (void)addCanvasViewController:(UIViewController *)canvasViewController;

/**
 *  Notifies the delegate when a canvas view controller should be removed.
 */
- (void)removeCanvasViewController:(UIViewController *)canvasViewControllerToRemove;

/**
 *  Notifies the delegate when a new inspector viewController should be added. This SHOULD automatically remove old inspector viewControllers. 
 *  The inspectorViewController parameter may be nil indicating no new inspectorViewController is needed.
 */
- (void)setInspectorViewController:(UIViewController *)inspectorViewController;

@end

/**
 *  Manages an array of tools and their respective canvas/inspector viewControllers as they become selected/deselected.
 */
@interface VToolController : NSObject

- (instancetype)initWithTools:(NSArray /* NSArray of tools that conform to <VWorkspaceTool> */ *)tools NS_DESIGNATED_INITIALIZER;

/**
 *  Call this method to export an asset.
 */
- (void)exportWithSourceAsset:(NSURL *)source
               withCompletion:(void (^)(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage))completion;
/**
 *  Must be implemented by subclasses! Only works on the first call.
 */
- (void)setupDefaultTool;

/**
 *  The tools passed in to the designated initializer.
 */
@property (nonatomic, readonly) NSArray *tools;

/**
 *  The currently selected tool.
 */
@property (nonatomic, strong) id <VWorkspaceTool> selectedTool;

/**
 *  The canvas view to be modified while tools are mutating.
 */
@property (nonatomic, strong) VCanvasView *canvasView;

/**
 *  The delegate to notify about new canvas/inspector viewControllers.
 */
@property (nonatomic, weak) id <VToolControllerDelegate> delegate;

@end
