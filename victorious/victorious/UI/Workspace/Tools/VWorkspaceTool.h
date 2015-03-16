//
//  VWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VCanvasView;

/**
 *  VWorkspaceTool defines a common interface for all workspace tools. Tools must specify their tool's location in the workspace and the UIViewController to use.
 */
@protocol VWorkspaceTool <NSObject>

@optional

#pragma mark - Rendering

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage; ///< A hook into the rendering process that each tool can use to apply its effects. Top-level tools must implement this method

@property (nonatomic, readonly) NSInteger renderIndex; ///< The index at which this tool should be applied. Lower comes first. Top-level tools must implement this method

#pragma mark - Editing

/**
 *  Called when tool is selected / deselected.
 */
@property (nonatomic, assign) BOOL selected;

/**
 *  Tools should implement this getter if they would like their UI to remain layered on top of the canvas. However their canavsToolViewController's View will have its userInteractionEnabled property set to NO. Upon reselection of the tool the workspace will re-enable interaction on the canavsToolViewController's View.
 */
@property (nonatomic, readonly) BOOL shouldLeaveToolOnCanvas;

- (void)setCanvasView:(VCanvasView *)canvasView;

- (void)setSharedCanvasToolViewController:(UIViewController *)viewController;

@property (nonatomic, strong, readonly) UIViewController *canvasToolViewController; ///< The tool to display in the canvas if any.
@property (nonatomic, strong, readonly) UIViewController *inspectorToolViewController; ///< The tool to display in the inspector if any.

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display while selecting tool.
@property (nonatomic, strong, readonly) UIImage *icon; ///< The icon to display for this tool.
@property (nonatomic, strong, readonly) UIImage *iconSelected; ///< The icon to display for this tool.

@end
