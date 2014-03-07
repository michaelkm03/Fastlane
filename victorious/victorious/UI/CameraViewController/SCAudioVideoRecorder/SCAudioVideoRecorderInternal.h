//
//  SCAudioVideoRecorderInternal.h
//  SCVideoRecorder
//

#import <Foundation/Foundation.h>
#import "SCAudioVideoRecorder.h"

@interface SCAudioVideoRecorder() {
    
}

//
// Internal methods and fields
//
- (void) prepareWriterAtSourceTime:(CMTime)sourceTime fromEncoder:(SCDataEncoder*)encoder;
- (void) dispatchBlockOnAskedQueue:(void(^)())block;
+ (NSError*) createError:(NSString*)name;

@property (assign, nonatomic) BOOL shouldComputeOffset;
@property (assign, nonatomic) CMTime startedTime;
@property (assign, nonatomic) CMTime currentTimeOffset;
@property (assign, nonatomic) CMTime lastFrameTimeBeforePause;
@property (strong, nonatomic) dispatch_queue_t dispatch_queue;
@property (strong, nonatomic) AVAssetWriter * assetWriter;

@end
