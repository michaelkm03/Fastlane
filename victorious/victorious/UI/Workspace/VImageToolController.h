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
    VImageToolControllerInitialImageEditStateCrop,
    VImageToolControllerInitialImageEditStateFilter,
    VImageToolControllerInitialImageEditStateText, // Default
};

@interface VImageToolController : VToolController

@property (nonatomic, assign) VImageToolControllerInitialImageEditState defaultImageTool;

@property (nonatomic, readonly) NSString *filterName; ///< The currently selected filter name.
@property (nonatomic, readonly) NSString *embeddedText; ///< The embedded text, if any.
@property (nonatomic, readonly) NSString *textToolType; ///< The text tool type, if any.
@property (nonatomic, readonly) BOOL didCrop; ///< Whether or not the user did crop.

@end
