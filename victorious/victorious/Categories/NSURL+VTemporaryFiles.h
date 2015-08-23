//
//  NSURL+VTemporaryFiles.h
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VTemporaryFiles)

/**
 *  A convenience method for generating URLs in the temp directory 
 *  for the application nested inside of a temp directory where appropriate.
 */
+ (NSURL *)v_temporaryFileURLWithExtension:(NSString *)extension inDirectory:(NSString *)directory;

@end
