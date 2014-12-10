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

#pragma mark - Rendering

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage; ///< A hook into the rendering process that each tool can use to apply its effects.

@property (nonatomic, readonly) NSInteger renderIndex; ///< The index at which this tool should be applied. Lower comes first.

@optional

#pragma mark - Editing

/*
 Tools should implement this getter if they would like their UI to remain layered on top of the canvas. However their canavsToolViewController's View will have its userInteractionEnabled property set to NO. Upon reselection of the tool the workspace will re-enable interaction on the canavsToolViewController's View.
 */
@property (nonatomic, readonly) BOOL shouldLeaveToolOnCanvas;

- (void)setCanvasView:(VCanvasView *)canvasView;

@property (nonatomic, strong, readonly) UIViewController *canvasToolViewController; ///< The tool to display in the canvas if any.
@property (nonatomic, strong, readonly) UIViewController *inspectorToolViewController; ///< The tool to display in the inspector if any.

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display while selecting tool.
@property (nonatomic, strong, readonly) UIImage *icon; ///< The icon to display for this tool.
@property (nonatomic, copy) void (^onCanvasToolUpdate)(void); ///< Tools should call this to inform the workspace they need to swap their canvas ToolVC.

@end
