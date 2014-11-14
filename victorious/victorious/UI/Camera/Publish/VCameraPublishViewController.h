//
//  VCameraPublishViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"

NSString * const VCameraPublishViewControllerDidPublishNotification;
NSString * const VCameraPublishViewControllerDidCancelhNotification;

@interface VCameraPublishViewController : UIViewController

@property (nonatomic, strong)   UIImage        *previewImage;
@property (nonatomic, strong)   NSURL          *mediaURL;
@property (nonatomic, strong)   NSString       *expirationDateString;

@property (nonatomic)   VPlaybackSpeed          playBackSpeed;
@property (nonatomic)   VLoopType               playbackLooping;
@property (nonatomic)   VCaptionType            captionType;

@property (nonatomic)   NSInteger               parentNodeID;
@property (nonatomic)   NSInteger               parentSequenceID;
@property (nonatomic)   BOOL                    didSelectAssetFromLibrary;

/**
 This block will be called when the user has finished publishing
 
 @param completed YES if the user chose to publish, NO if the 
                      user cancelled or an error occurred.
 */
@property (nonatomic, copy) void (^completion)(BOOL completed);

+ (VCameraPublishViewController *)cameraPublishViewController;

@end
