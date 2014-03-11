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

@property (nonatomic, strong)   AVAsset*    sourceAsset;
@property (nonatomic)           BOOL        addAudio;
@property (nonatomic, strong)   NSURL*      outputURL;

- (void)processVideo:(AVAsset *)aVideoAsset timeRange:(CMTimeRange)aTimeRange;

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;
- (void)processVideoDidFinishWithURL:(NSURL *)aURL;

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller;

- (void)exportDidFinish:(AVAssetExportSession*)session;
- (NSURL *)exportFileURL;

@end
