//
//  VWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VWorkspaceToolLocation)
{
    VWorkspaceToolLocationInspector,
    VWorkspaceToolLocationCanvas,
};

/**
 *  VWorkspaceTool defines a common interface for all workspace tools. Tools must specify their tool's location in the workspace and the UIViewController to use.
 */
@protocol VWorkspaceTool <NSObject>

@required
@property (nonatomic, assign, readonly) VWorkspaceToolLocation toolLocation; ///< The location to display this tool's UI.
@property (nonatomic, strong, readonly) UIViewController *toolViewController; ///< The interface for this tool.

@optional
@property (nonatomic, copy, readonly) NSString *title; ///< The text to display while selecting tool.
@property (nonatomic, strong, readonly) UIImage *icon; ///< The icon to display for this tool.

@end
