//
//  VUploadTaskInformation.m
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VUploadTaskInformation.h"

@implementation VUploadTaskInformation

- (id)init
{
    self = [super init];
    if ( self != nil )
    {
        _identifier = [NSUUID UUID];
        _expectedBytesToSend = 0;
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request previewImage:(UIImage *)previewImage bodyFilename:(NSString *)bodyFilename description:(NSString *)uploadDescription isGif:(BOOL)isGif
{
    self = [self init];
    if ( self != nil )
    {
        _request = [request copy];
        _previewImage = previewImage;
        _bodyFilename = bodyFilename;
        _uploadDescription = [uploadDescription copy];
        _isGif = isGif;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if ( self != nil )
    {
        _request = [aDecoder decodeObjectOfClass:[NSURLRequest class] forKey:NSStringFromSelector(@selector(request))];
        _bodyFilename = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(bodyFilename))];
        _uploadDescription = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(uploadDescription))];
        _identifier = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:NSStringFromSelector(@selector(identifier))];
        _isGif = [aDecoder decodeBoolForKey:@"isGif"];
        
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
    [aCoder encodeObject:self.bodyFilename forKey:NSStringFromSelector(@selector(bodyFilename))];
    [aCoder encodeObject:self.uploadDescription forKey:NSStringFromSelector(@selector(uploadDescription))];
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeBool:self.isGif forKey:@"isGif"];
    [aCoder encodeObject:UIImageJPEGRepresentation(self.previewImage, VConstantJPEGCompressionQuality) forKey:NSStringFromSelector(@selector(previewImage))];
}

#pragma mark - NSObject

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


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, identifier: %@, request: %@, bodyFileName: %@, uploadDescription: %@, isGifType: %s", [super description], self.identifier, self.request, self.bodyFilename, self.uploadDescription, self.isGif ? "true" : "false"];
}

@end
