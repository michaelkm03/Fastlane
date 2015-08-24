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
 *
 *  @param extension An optional filename extension for the temporary file URL. May be nil.
 *  @param directory A nonoptional directory name located in the temp folder for this application.
 *  Will be created if doesn't already exist. May not be nil.
 *
 *  @return A temporary URL file path for saving items to the temporary directory or nil
 *  if the filepath was unable to be created.
 */
+ (nullable NSURL *)v_temporaryFileURLWithExtension:(nullable NSString *)extension
                                        inDirectory:(nonnull NSString *)directory;

@end
