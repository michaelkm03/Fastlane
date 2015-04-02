//
//  VHashtagTool.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"
#import "VMultipleToolPicker.h"
#import "VCollectionToolPicker.h"

/**
 A workspace tool that provides a picker for selecting one or more hashtags
 from a list to add into a text post.
 */
@interface VHashtagTool : NSObject <VWorkspaceTool>

/**
 The inspector tool picker too that ptovides the browsing and multiple selection functionality.
 */
@property (nonatomic, readonly) UIViewController <VCollectionToolPicker, VMultipleToolPicker> *toolPicker;

@end
