//
//  VUploadTaskCreator.m
//  victorious
//
//  Created by Josh Hinman on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskCreator.h"

@import VictoriousIOSSDK;

@implementation VUploadTaskCreator

- (instancetype)initWithUploadManager:(VUploadManager *)uploadManager
{
    NSParameterAssert(uploadManager != nil);
    self = [super init];
    if ( self != nil )
    {
        _uploadManager = uploadManager;
    }
    return self;
}

- (VUploadTaskInformation *)createUploadTaskWithError:(NSError *__autoreleasing *)error
{
    NSURL *bodyFileURL = [self.uploadManager urlForNewUploadBodyFile];
    NSURL *bodyFileDirectoryURL = [bodyFileURL URLByDeletingLastPathComponent];
    
    NSError *directoryError = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:bodyFileDirectoryURL withIntermediateDirectories:YES attributes:nil error:&directoryError])
    {
        if (error)
        {
            *error = directoryError;
        }
        return nil;
    }
    
    VMultipartFormDataWriter *multipartWriter = [[VMultipartFormDataWriter alloc] initWithOutputFileURL:bodyFileURL];
    
    __block BOOL success = YES;
    __block BOOL isGif = NO;
    [self.formFields enumerateKeysAndObjectsUsingBlock:^(NSString *fieldName, id value, BOOL *stop)
    {
        NSAssert([fieldName isKindOfClass:[NSString class]], @"The formFields dictionary has an incorrect key type");

        if ([value isKindOfClass:[NSString class]])
        {
            if (![multipartWriter appendPlaintext:value withFieldName:fieldName error:error])
            {
                success = NO;
            }

            if ([fieldName isEqualToString:@"is_gif_style"]) {
                isGif = ([value isEqualToString:@"true"]) ? YES : NO;
            }
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
            
            success = [multipartWriter appendFileWithName:[fieldName stringByAppendingPathExtension:pathExtension]
                                              contentType:mimeType
                                                  fileURL:value
                                                fieldName:fieldName
                                                    error:error];
            if (!success)
            {
                [multipartWriter closeOutputFileWithoutFinishing];
                *stop = YES;
            }
        }
        else if (value == [NSNull null])
        {
            // noop
            return;
        }
        else
        {
            NSAssert(false, @"The formFields dictionary has an incorrect value type");
        }
    }];
    
    if (success)
    {
        if (![multipartWriter finishWritingWithError:error])
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    
    NSMutableURLRequest *request = [self.request mutableCopy] ?: [[NSMutableURLRequest alloc] init];
    [request setValue:[multipartWriter contentTypeHeader] forHTTPHeaderField:@"Content-Type"];

    VUploadTaskInformation *uploadTask = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:self.previewImage bodyFilename:bodyFileURL.lastPathComponent description:self.uploadDescription isGif:isGif];
    return uploadTask;
}

@end
