//
//  VTrimVideoTool.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoWorkspaceTool.h"
#import "VHasManagedDependencies.h"

@import CoreMedia;
@import AVFoundation;

@class VTrimVideoTool;

/**
 *  Objects should conform to this protocol to be notified of failures.
 */
@protocol VTrimVideoToolDelegate <NSObject>

/**
 *  Informs degates that the trim tool encountered a catastrophic failure and 
 *  will not continue to funciton.
 */
- (void)trimVideoToolFailed:(VTrimVideoTool *)trimVideoTool;

@end

@interface VTrimVideoTool : NSObject <VVideoWorkspaceTool, VHasManagedDependencies>

/**
 *  Whether or not the user did trim.
 */
@property (nonatomic, readonly) BOOL didTrim;

/**
 *  Whether or not the selected tool is a gif.
 */
@property (nonatomic, readonly) BOOL isGIF;

/**
 *  Delegates will be informed of failures.
 */
@property (nonatomic, weak) id <VTrimVideoToolDelegate> delegate;

@end
