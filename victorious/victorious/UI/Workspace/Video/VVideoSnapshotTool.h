//
//  VMemeVideoTool.h
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoWorkspaceTool.h"
#import "VHasManagedDependencies.h"

/**
 *  A video snapshot tool. Responsible for managing a video player and UI for taking a snapshot.
 */
@interface VVideoSnapshotTool : NSObject <VVideoWorkspaceTool, VHasManagedDependencies>

/**
 *  A completion block for when the tool has captured a snapshot. Includes a preview image and URL for the rendered snapshot.
 */
@property (nonatomic, copy) void (^capturedSnapshotBlock) (UIImage *previewImage, NSURL *renderedMediaURL);

@end
