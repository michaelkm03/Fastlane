//
//  VTextColorTool.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"
#import "VEditTextToolViewController.h"

@class VTickerPickerViewController;

@interface VTextColorTool : NSObject <VWorkspaceTool>

@property (nonatomic, strong, readonly) VTickerPickerViewController *toolPicker;

@end
