//
//  VMultipartFormDataWriter.m
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMultipartFormDataWriter.h"

static NSString * const kDefaultBoundary = @"M9EzbDHvJfWcrApoq3eUJWs3UF";

@interface VMultipartFormDataWriter ()

@property (nonatomic, strong) dispatch_queue_t outputQueue; ///< Serializes file writing
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation VMultipartFormDataWriter

- (instancetype)initWithOutputFileURL:(NSURL *)outputFileURL
{
    NSParameterAssert(outputFileURL != nil);
    self = [super init];
    if (self)
    {
        _outputQueue = dispatch_queue_create("VMultipartFormDataWriter.outputQueue", DISPATCH_QUEUE_SERIAL);
        _outputFileURL = outputFileURL;
        _boundary = kDefaultBoundary;
    }
    return self;
}

- (void)dealloc
{
    if (_outputStream)
    {
        VLog("WARNING: VMultipartFormDataWriter is being deallocated with its stream still open. Always call -finishWriting to close the stream before deallocating!");
    }
}

- (NSString *)contentTypeHeader
{
    return [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", self.boundary];
}

- (void)startWriting
{
    self.outputStream = [NSOutputStream outputStreamWithURL:self.outputFileURL append:NO];
    [self.outputStream open];
}

- (BOOL)appendPlaintext:(NSString *)s withFieldName:(NSString *)fieldName error:(NSError *__autoreleasing *)error
{
    __block BOOL success = YES;
    dispatch_sync(self.outputQueue, ^(void)
    {
        if (![self appendDelimiterWithError:error])
        {
            success = NO;
            return;
        }
        if (![self appendHeadersWithFieldName:fieldName filename:nil contentType:@"text/plain; charset=UTF-8" error:error])
        {
            success = NO;
            return;
        }
        if (![self appendData:[s dataUsingEncoding:NSUTF8StringEncoding] error:error])
        {
            success = NO;
            return;
        }
    });
    return success;
}

- (BOOL)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                    stream:(NSInputStream *)inputStream
                 fieldName:(NSString *)fieldName
                     error:(NSError *__autoreleasing *)error
{
    __block BOOL success = YES;
    dispatch_sync(self.outputQueue, ^(void)
    {
        if (![self appendDelimiterWithError:error])
        {
            success = NO;
            return;
        }
        if (![self appendHeadersWithFieldName:fieldName filename:filename contentType:contentType error:error])
        {
            success = NO;
            return;
        }
        
        const NSUInteger bufferLen = 2048;
        uint8_t buffer[bufferLen];
        while (inputStream.hasBytesAvailable)
        {
            NSInteger size = [inputStream read:buffer maxLength:bufferLen];
            if (size > 0)
            {
                if ([self.outputStream write:buffer maxLength:size] == -1)
                {
                    if (error)
                    {
                        *error = self.outputStream.streamError;
                    }
                    success = NO;
                    break;
                }
            }
            else if (size < 0)
            {
                if (error)
                {
                    *error = inputStream.streamError;
                }
                success = NO;
                break;
            }
        }
    });
    return success;
}

- (BOOL)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                   fileURL:(NSURL *)fileURL
                 fieldName:(NSString *)fieldName
                     error:(NSError *__autoreleasing *)error
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:fileURL];
    [inputStream open];
    BOOL success = [self appendFileWithName:filename contentType:contentType stream:inputStream fieldName:fieldName error:error];
    [inputStream close];
    return success;
}

- (BOOL)appendDelimiterWithError:(NSError *__autoreleasing *)error
{
    NSString *delimiter = [NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary];
    return [self appendASCIIString:delimiter error:error];
}

- (NSString *)contentDispositionHeaderWithFieldName:(NSString *)fieldName filename:(NSString *)filename
{
    NSMutableString *header = [[NSMutableString alloc] init];
    [header appendString:@"Content-Disposition: form-data"];
    
    if (fieldName.length)
    {
        [header appendString:[NSString stringWithFormat:@"; name=\"%@\"", fieldName]];
    }
    if (filename.length)
    {
        [header appendString:[NSString stringWithFormat:@"; filename=\"%@\"", filename]];
    }
    
    [header appendString:@"\r\n"];
    return header;
}

- (BOOL)appendHeadersWithFieldName:(NSString *)fieldName filename:(NSString *)filename contentType:(NSString *)contentType error:(NSError *__autoreleasing *)error
{
    NSString *contentDispositionHeader = [self contentDispositionHeaderWithFieldName:fieldName filename:filename];
    if (![self appendASCIIString:contentDispositionHeader error:error])
    {
        return NO;
    }
    
    if (contentType.length)
    {
        NSString *contentTypeHeader = [NSString stringWithFormat:@"Content-Type: %@\r\n", contentType];
        if (![self appendASCIIString:contentTypeHeader error:error])
        {
            return NO;
        }
    }
    
    return [self appendASCIIString:@"\r\n" error:error];
}

- (BOOL)appendASCIIString:(NSString *)string error:(NSError *__autoreleasing *)error
{
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [self appendData:data error:error];
}

- (BOOL)appendData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if (!self.outputStream)
    {
        [self startWriting];
    }
    const NSUInteger bufferLen = 2048;
    uint8_t buffer[bufferLen];
    for (NSUInteger i = 0; i < data.length; i += bufferLen)
    {
        NSUInteger size = MIN(data.length - i, bufferLen);
        [data getBytes:buffer range:NSMakeRange(i, size)];
        if ([self.outputStream write:buffer maxLength:size] == -1)
        {
            if (error)
            {
                *error = self.outputStream.streamError;
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)finishWritingWithError:(NSError *__autoreleasing *)error
{
    __block BOOL success = YES;
    dispatch_sync(self.outputQueue, ^(void)
    {
        success = [self appendASCIIString:[NSString stringWithFormat:@"\r\n--%@--", self.boundary] error:error];
        [self.outputStream close];
        self.outputStream = nil;
    });
    return success;
}

- (void)closeOutputFileWithoutFinishing
{
    dispatch_sync(self.outputQueue, ^(void)
    {
        [self.outputStream close];
        self.outputStream = nil;
    });
}

@end
