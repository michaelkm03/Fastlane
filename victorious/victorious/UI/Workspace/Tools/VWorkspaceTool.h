//
//  VWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  VWorkspaceTool defines a common interface for all workspace tools. Tools must specify their tool's location in the workspace and the UIViewController to use.
 */
@protocol VWorkspaceTool <NSObject>

@required
@property (nonatomic, strong, readonly) UIViewController *canvasToolViewController; ///< The tool to display in the canvas if any.
@property (nonatomic, strong, readonly) UIViewController *inspectorToolViewController; ///< The tool to display in the inspector if any.

@optional
@property (nonatomic, copy, readonly) NSString *title; ///< The text to display while selecting tool.
@property (nonatomic, strong, readonly) UIImage *icon; ///< The icon to display for this tool.
@property (nonatomic, copy) void (^onCanvasToolUpdate)(void); ///< Called whenever a subtool has been selected that needs to swap tools on the canvas

@end
