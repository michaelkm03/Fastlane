//
//  VUploadTaskInformation.m
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VUploadTaskInformation.h"

@implementation VUploadTaskInformation

- (instancetype)initWithRequest:(NSURLRequest *)request bodyFileURL:(NSURL *)bodyFileURL description:(NSString *)uploadDescription
{
    self = [super init];
    if (self)
    {
        _request = [request copy];
        _bodyFileURL = bodyFileURL;
        _uploadDescription = [uploadDescription copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _request = [aDecoder decodeObjectOfClass:[NSURLRequest class] forKey:NSStringFromSelector(@selector(request))];
        _bodyFileURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:NSStringFromSelector(@selector(bodyFileURL))];
        _uploadDescription = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(uploadDescription))];
    }
    return self;
}

#pragma mark - NSCoding methods

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.request forKey:NSStringFromSelector(@selector(request))];
    [aCoder encodeObject:self.bodyFileURL forKey:NSStringFromSelector(@selector(bodyFileURL))];
    [aCoder encodeObject:self.uploadDescription forKey:NSStringFromSelector(@selector(uploadDescription))];
}

@end
