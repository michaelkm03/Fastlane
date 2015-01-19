//
//  VImageToolController.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

extern NSString * const VImageToolControllerInitialImageEditStateKey;
typedef NS_ENUM(NSInteger, VImageToolControllerInitialImageEditState)
{
    VImageToolControllerInitialImageEditStateCrop, // Default
    VImageToolControllerInitialImageEditStateFilter,
    VImageToolControllerInitialImageEditStateText,
};

@interface VImageToolController : VToolController

@property (nonatomic, assign) VImageToolControllerInitialImageEditState defaultImageTool;

@end
