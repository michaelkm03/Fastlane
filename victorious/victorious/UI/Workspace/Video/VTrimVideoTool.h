//
//  VTrimVideoTool.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"
#import "VHasManagedDependencies.h"

@import CoreMedia;
@import AVFoundation;

@interface VTrimVideoTool : NSObject <VWorkspaceTool, VHasManagedDependancies>

@property (nonatomic, strong) NSURL *mediaURL;

@property (nonatomic, readonly) CMTime desiredFrameDuration;

@property (nonatomic, readonly) AVPlayerItem *playerItem;

@property (nonatomic, copy) void (^playerItemReady)(AVPlayerItem *playerItem); // A completion block for when the video is ready to be played.

@property (nonatomic, readonly) AVAssetExportSession *exportSession;

@end
