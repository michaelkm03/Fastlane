//
//  VDownloadTaskInformation.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDownloadTaskInformation : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request
               downloadLocation:(NSURL *)downloadLocation NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, readonly) NSURL *downloadLocation;

@end
