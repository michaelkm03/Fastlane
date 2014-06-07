//
//  VVideoLightboxViewController.h
//  victorious
//
//  Created by Josh Hinman on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLightboxViewController.h"

/**
 VLightboxViewController subclass that light boxes a video player.
 */
@interface VVideoLightboxViewController : VLightboxViewController

@property (nonatomic, readonly) UIImage   *previewImage;
@property (nonatomic, readonly) NSURL     *videoURL;
@property (nonatomic, copy)     void     (^onVideoFinished)(void); ///< Called when the video plays through to the end
@property (nonatomic, copy)     NSString  *titleForAnalytics; ///< If set, analytics events will use this property for the "label" parameter
@property (nonatomic)           BOOL       shouldFireAnalytics; ///< Set to NO to disable analytics. YES by default.

/**
 Creates a new instance of a video lightbox view controller.
 
 @param previewImage An image to display while the video is loading
 @param videoURL     The video URL to play
 */
- (instancetype)initWithPreviewImage:(UIImage *)previewImage videoURL:(NSURL *)videoURL;

@end
