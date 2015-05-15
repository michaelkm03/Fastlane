//
//  VToolPicker.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

@protocol VToolPicker;

@class VTickerPickerViewController;

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPickerDelegate <NSObject>

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectTool:(id<VWorkspaceTool>)tool;

@end

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPicker <NSObject>

@property (nonatomic, strong) id<VToolPickerDelegate> pickerDelegate;

@property (nonatomic, readonly) id <VWorkspaceTool> selectedTool; ///< The currently selected tool, if any.

@end

