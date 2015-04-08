//
//  VDownloadTaskInformation.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 *
 *  This has not been fully engineered for general use. Only supports one download task at a time.
 *
 */
@interface VDownloadTaskInformation : NSObject

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
               downloadLocation:(NSURL *)downloadLocation NS_DESIGNATED_INITIALIZER;

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 */
@property (nonatomic, readonly) NSURLRequest *request;

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 */
@property (nonatomic, readonly) NSURL *downloadLocation;

@end
