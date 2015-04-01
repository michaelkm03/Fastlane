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

@interface VHashtagTool : NSObject <VWorkspaceTool>

@property (nonatomic, readonly) UIViewController <VCollectionToolPicker, VMultipleToolPicker> *toolPicker;

@end
