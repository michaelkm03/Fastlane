//
//  VMessage+Fetcher.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessage.h"

/**
 An enum which describes the type of media attached
 to a message.
 */
typedef NS_ENUM(NSInteger, VMessageMediaType)
{
    VMessageMediaTypeNoMedia,
    VMessageMediaTypeImage,
    VMessageMediaTypeVideo,
    VMessageMediaTypeGIF
};

@interface VMessage (Fetcher)

/**
 Returns an enum which describes the type of media attached
 to this message.
 */
- (VMessageMediaType)messageMediaType;

/**
 Returns YES if message has a media attachment
 */
- (BOOL)hasMediaAttachment;

/**
 Returns the URL for this message's preview image
 */
- (NSURL *)previewImageURL;

/**
 Returns the proper media URL if this message contains
 attached media, and nil if it does not.
 */
- (NSURL *)properMediaURLGivenContentType;

@end
