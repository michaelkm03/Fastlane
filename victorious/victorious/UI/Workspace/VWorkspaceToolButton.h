//
//  VWorkspaceToolButton.h
//  victorious
//
//  Created by Michael Sena on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

/**
 *  VWorkspaceToolButtons are used to signify selection of a particular tool
 *  within the workspace. Draws a colored circle behind an icon for the tool.
 *  Color swaps between selected and unselected variants.
 */
@interface VWorkspaceToolButton : UIButton

/**
 *  Assigna tool to this property and the tool button will grab an icon from this tool.
 */
@property (nonatomic, weak) id <VWorkspaceTool> tool;

/**
 *  A color representing the selected state.
 */
@property (nonatomic, copy) UIColor *selectedColor;

/**
 *  A color representing the unselected state.
 */
@property (nonatomic, copy) UIColor *unselectedColor;

@end
