//
//  VUploadTaskCreator.m
//  victorious
//
//  Created by Josh Hinman on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMultipartFormDataWriter.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskCreator.h"

@implementation VUploadTaskCreator

- (instancetype)initWithUploadManager:(VUploadManager *)uploadManager
{
    NSParameterAssert(uploadManager != nil);
    self = [super init];
    if (self)
    {
        _uploadManager = uploadManager;
    }
    return self;
}

- (VUploadTaskInformation *)uploadTask
{
    NSURL *temporaryFileURL = [self.uploadManager urlForNewUploadBodyFile];
    VMultipartFormDataWriter *multipartWriter = [[VMultipartFormDataWriter alloc] initWithOutputFileURL:temporaryFileURL];
    
    [self.formFields enumerateKeysAndObjectsUsingBlock:^(NSString *fieldName, id value, BOOL *stop)
    {
        NSAssert([fieldName isKindOfClass:[NSString class]], @"The formFields dictionary has an incorrect key type");

        if ([value isKindOfClass:[NSString class]])
        {
            [multipartWriter appendPlaintext:value withFieldName:fieldName];
        }
        else if ([value isKindOfClass:[NSURL class]])
        {
            NSString *mimeType = @"application/octet-stream";
            NSString *pathExtension = [value pathExtension];
            CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)pathExtension, NULL);
            if (type)
            {
                mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
                CFRelease(type);
            }
            
            [multipartWriter appendFileWithName:[fieldName stringByAppendingPathExtension:pathExtension]
                                    contentType:mimeType
                                        fileURL:value
                                      fieldName:fieldName];
        }
        else if (value == [NSNull null])
        {
            return;
        }
        else
        {
            NSAssert(false, @"The formFields dictionary has an incorrect value type");
        }
    }];
    [multipartWriter finishWriting];
    
    NSMutableURLRequest *request = [self.request mutableCopy] ?: [[NSMutableURLRequest alloc] init];
    [request setValue:[multipartWriter contentTypeHeader] forHTTPHeaderField:@"Content-Type"];
    
    VUploadTaskInformation *uploadTask = [[VUploadTaskInformation alloc] init];
    uploadTask.request = request;
    uploadTask.bodyFileURL = temporaryFileURL;
    return uploadTask;
}

@end
