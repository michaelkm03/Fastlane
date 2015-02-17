//
//  VMemeVideoTool.h
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoWorkspaceTool.h"
#import "VHasManagedDependencies.h"

@interface VVideoSnapshotTool : NSObject <VVideoWorkspaceTool, VHasManagedDependancies>

@property (nonatomic, copy) void (^capturedSnapshotBlock) (UIImage *previewImage, NSURL *renderedMediaURL);

@end
