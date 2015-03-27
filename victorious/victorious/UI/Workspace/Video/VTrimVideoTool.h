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

@interface VTrimVideoTool : NSObject <VVideoWorkspaceTool, VHasManagedDependencies>

/**
 *  Whether or not the user did trim.
 */
@property (nonatomic, readonly) BOOL didTrim;

/**
 *  Whether or not the selected tool is a gif.
 */
@property (nonatomic, readonly) BOOL isGIF;

@end
