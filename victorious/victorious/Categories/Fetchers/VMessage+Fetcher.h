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
 to this message.
 */
typedef NS_ENUM(NSInteger, VMessageMediaType)
{
    VMessageMediaTypeNoMedia,
    VMessageMediaTypeImage,
    VMessageMediaTypeVideo
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

@end
