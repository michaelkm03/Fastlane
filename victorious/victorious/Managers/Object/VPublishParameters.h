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
 *  Upload a new media item and create a sequence for that item.
 *
 *  name             The name or caption of the sequence.
 *  previewImage     A preview image of the sequence.
 *  type             The VCaptionType used on the sequence.
 *  parentSequenceId The parent sequence id if this is a remix.
 *  parentNodeId     The parent node id of this is a remix.
 *  loopType         The loop type if this is a video.
 *  mediaUrl         The media url to use for uploading.
 *  isGIF            Whether or not this is a gif asset.
 *  didCrop          Whether or not the user did use the crop feature.
 *  didTrim          Whether or not the user trimmed.
 *  filterName       The name of the filter used.
 *  embeddedText     The embedded text in the image if the user embedded text.
 *  textToolType     The text tool type (ex: MEME).
 */

@interface VPublishParameters : NSObject

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, assign) VCaptionType captionType;
@property (nonatomic, strong) NSNumber *parentSequenceID;
@property (nonatomic, strong) NSNumber *parentNodeID;
@property (nonatomic, assign) VLoopType loopType;
@property (nonatomic, strong) NSURL *mediaToUploadURL;
@property (nonatomic, assign) BOOL isGIF;
@property (nonatomic, assign) BOOL didCrop;
@property (nonatomic, assign) BOOL didTrim;
@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, copy) NSString *embeddedText;
@property (nonatomic, copy) NSString *textToolType;
@property (nonatomic, assign) BOOL shouldSaveToCameraRoll;

@end
