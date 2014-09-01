//
//  VPhotoFilterSerialization.h
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Creates an array of VPhotoFilter objects from a plist file
 */
@interface VPhotoFilterSerialization : NSObject

+ (NSArray /* VPhotoFilter */ *)filtersFromPlistFile:(NSURL *)fileURL;

@end
