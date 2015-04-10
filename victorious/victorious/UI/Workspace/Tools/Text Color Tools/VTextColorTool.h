//
//  VTextColorTool.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"
#import "VTextCanvasToolViewController.h"

@class VTickerPickerViewController;

/**
 A workspace tool that provides a picker for selecting a color to be used
 in the creaiton of a text post.
 */
@interface VTextColorTool : NSObject <VWorkspaceTool>

/**
 A picker used for selectin a single color.
 */
@property (nonatomic, strong, readonly) VTickerPickerViewController *toolPicker;

@end
