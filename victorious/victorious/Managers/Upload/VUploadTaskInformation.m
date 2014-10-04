//
//  VUploadTaskInformation.m
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VObjectManager+Private.h"
#import "VUploadTaskInformation.h"

@implementation VUploadTaskInformation

- (id)init
{
    self = [super init];
    if (self)
    {
        _identifier = [NSUUID UUID];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request previewImage:(UIImage *)previewImage bodyFileURL:(NSURL *)bodyFileURL description:(NSString *)uploadDescription
{
    self = [self init];
    if (self)
    {
        _request = [request copy];
        _previewImage = previewImage;
        _bodyFileURL = bodyFileURL;
        _uploadDescription = [uploadDescription copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        _request = [aDecoder decodeObjectOfClass:[NSURLRequest class] forKey:NSStringFromSelector(@selector(request))];
        _bodyFileURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:NSStringFromSelector(@selector(bodyFileURL))];
        _uploadDescription = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(uploadDescription))];
        _identifier = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:NSStringFromSelector(@selector(identifier))];
        
        NSData *previewImageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(previewImage))];
        if (previewImageData)
        {
            _previewImage = [UIImage imageWithData:previewImageData];
        }
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
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:UIImageJPEGRepresentation(self.previewImage, VConstantJPEGCompressionQuality) forKey:NSStringFromSelector(@selector(previewImage))];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[VUploadTaskInformation class]])
    {
        return [self.identifier isEqual:[(VUploadTaskInformation *)object identifier]];
    }
    return NO;
}

@end
