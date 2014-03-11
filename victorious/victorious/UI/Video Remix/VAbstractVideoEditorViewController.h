//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

@interface VAbstractVideoEditorViewController : UIViewController

@property (nonatomic, strong)       NSURL*  sourceURL;
@property (nonatomic, readwrite)    BOOL    addAudio;

- (void)processVideo:(AVAsset *)aVideoAsset timeRange:(CMTimeRange)aTimeRange;

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;
- (void)processVideoDidFinishWithURL:(NSURL *)aURL;

- (NSURL *)exportFileURL;
- (void)exportDidFinish:(AVAssetExportSession*)session;

@end
