//
//  NSURL+MediaType.h
//  victorious
//
//  Created by Josh Hinman on 5/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MediaType)

- (BOOL)v_hasVideoExtension; ///< Returns YES if the receiver's pathExtension is a common video extension
- (BOOL)v_hasImageExtension; ///< Returns YES if the receiver's pathExtension is a common image extension
- (BOOL)v_hasGIFExtension; ///< Returns YES if the receiver's pathExtension is a gif extension

@end

@interface NSString (MediaType)

- (BOOL)v_hasVideoExtension; ///< Returns YES if the receiver's pathExtension is a common video extension
- (BOOL)v_hasImageExtension; ///< Returns YES if the receiver's pathExtension is a common image extension
- (BOOL)v_hasGIFExtension; ///< Returns YES if the receiver's pathExtension is a gif extension
- (BOOL)v_isExtensionMp4; ///< Returns YES if the receiver's pathExtension is an mp4 video extension

@end
