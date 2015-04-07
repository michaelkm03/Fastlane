//
//  VDownloadTaskInformation.m
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDownloadTaskInformation.h"

@implementation VDownloadTaskInformation

- (instancetype)initWithRequest:(NSURLRequest *)request
               downloadLocation:(NSURL *)downloadLocation
{
    self = [super init];
    if (self)
    {
        _request = [request copy];
        _downloadLocation = [downloadLocation copy];
    }
    return self;
}

@end
