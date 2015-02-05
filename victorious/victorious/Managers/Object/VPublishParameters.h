//
//  VPublishParameters.h
//  victorious
//
//  Created by Michael Sena on 1/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VConstants.h"

/**
 *  A simple model for sharing publish parameters among different objects.
 */
@interface VPublishParameters : NSObject

/**
 *  The name or caption of the sequence.
 */
@property (nonatomic, strong) NSString *caption;

/**
 *  A preview image to use in UI such as the upload bar/publish screen.
 */
@property (nonatomic, strong) UIImage *previewImage;

/**
 *  The VCaptionType used on the sequence.
 */
@property (nonatomic, assign) VCaptionType captionType;

/**
 *  The parent sequence id if this is a remix.
 */
@property (nonatomic, strong) NSNumber *parentSequenceID;

/**
 *  The parent node id if this is a remix.
 */
@property (nonatomic, strong) NSNumber *parentNodeID;

/**
 *  The loop type if this is a video.
 */
@property (nonatomic, assign) VLoopType loopType;

/**
 *  The media url to use for uploading.
 */
@property (nonatomic, strong) NSURL *mediaToUploadURL;

/**
 *  Whether or not this is a gif asset.
 */
@property (nonatomic, assign) BOOL isGIF;

/**
 *  Whether or not the user used the crop feature during creation of this asset.
 */
@property (nonatomic, assign) BOOL didCrop;

/**
 *  Whether or not the user trimmed.
 */
@property (nonatomic, assign) BOOL didTrim;

/**
 *  The name of the filter used.
 */
@property (nonatomic, copy) NSString *filterName;

/**
 *  The embedded text in the image if the user embedded text.
 */
@property (nonatomic, copy) NSString *embeddedText;

/**
 *  The text tool type (ex: MEME).
 */
@property (nonatomic, copy) NSString *textToolType;

/**
 *  A boolean indicating whether or not this asset should be saved to the user's camera roll on publish.
 */
@property (nonatomic, assign) BOOL shouldSaveToCameraRoll;

@end
