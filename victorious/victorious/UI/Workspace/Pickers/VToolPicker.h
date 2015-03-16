//
//  VToolPicker.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

@protocol VToolPickerDataSource;

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPicker <NSObject>

- (void)setDataSource:(id<VToolPickerDataSource>)dataSource;

- (void)setTools:(NSArray /* That implement VWorkspaceTool */ *)tools; ///< The tools to chose from. Retains a copy of the array.

@property (nonatomic, readonly) id <VWorkspaceTool> selectedTool; ///< The currently selected tool, if any.

@property (nonatomic, copy) void (^onToolSelection)(id <VWorkspaceTool> selectedTool); ///< A block that is called whenever a new tool has been selected.

@end
