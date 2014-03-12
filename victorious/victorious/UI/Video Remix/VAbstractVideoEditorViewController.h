//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

@interface VAbstractVideoEditorViewController : UIViewController

@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView*    activityIndicator;

@property (nonatomic, strong)           AVAsset*                    sourceAsset;
@property (nonatomic)                   BOOL                        addAudio;

@property (nonatomic, strong)           NSURL*                      outputURL;

- (void)processVideo:(AVAsset *)aVideoAsset timeRange:(CMTimeRange)aTimeRange;

- (AVMutableCompositionTrack *)insertTimeRange:(CMTimeRange)timeRange ofAsset:(AVAsset *)asset inComposition:(AVMutableComposition *)composition atTime:(CMTime)time;
- (AVMutableVideoCompositionLayerInstruction *)orientVideoAsset:(AVAsset *)asset videoTrack:(AVAssetTrack *)videoTrack atTime:(CMTime)time totalDuration:(CMTime)duration;
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;

- (void)exportComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition;
- (void)processVideoDidFinishWithURL:(NSURL *)aURL;

@end
