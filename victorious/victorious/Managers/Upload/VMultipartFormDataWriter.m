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
        VLog("WARNING: VMultipartFormDataWriter is being deallocated with its stream still open. Always call -finishWriting to close the stream before deallocating!")
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

- (void)appendPlaintext:(NSString *)s withFieldName:(NSString *)fieldName
{
    dispatch_async(self.outputQueue, ^(void)
    {
        [self appendDelimiter];
        [self appendHeadersWithFieldName:fieldName filename:nil contentType:@"text/plain; charset=\"UTF-8\""];
        [self appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
    });
}

- (void)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                    stream:(NSInputStream *)inputStream
                 fieldName:(NSString *)fieldName
{
    [self appendFileWithName:filename contentType:contentType stream:inputStream fieldName:fieldName closeWhenDone:NO];
}

- (void)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                    stream:(NSInputStream *)inputStream
                 fieldName:(NSString *)fieldName
             closeWhenDone:(BOOL)shouldClose
{
    dispatch_async(self.outputQueue, ^(void)
    {
        [self appendDelimiter];
        [self appendHeadersWithFieldName:fieldName filename:filename contentType:contentType];
        
        const NSUInteger bufferLen = 2048;
        uint8_t buffer[bufferLen];
        while (inputStream.hasBytesAvailable)
        {
            NSUInteger size = [inputStream read:buffer maxLength:bufferLen];
            if (size > 0)
            {
                [self.outputStream write:buffer maxLength:size];
            }
            else
            {
                break;
            }
        }
        
        if (shouldClose)
        {
            [inputStream close];
        }
    });
}

- (void)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                   fileURL:(NSURL *)fileURL
                 fieldName:(NSString *)fieldName
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:fileURL];
    [inputStream open];
    [self appendFileWithName:filename contentType:contentType stream:inputStream fieldName:fieldName closeWhenDone:YES];
}

- (void)appendDelimiter
{
    NSString *delimiter = [NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary];
    [self appendASCIIString:delimiter];
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

- (void)appendHeadersWithFieldName:(NSString *)fieldName filename:(NSString *)filename contentType:(NSString *)contentType
{
    NSString *contentDispositionHeader = [self contentDispositionHeaderWithFieldName:fieldName filename:filename];
    [self appendASCIIString:contentDispositionHeader];
    
    if (contentType.length)
    {
        NSString *contentTypeHeader = [NSString stringWithFormat:@"Content-Type: %@\r\n", contentType];
        [self appendASCIIString:contentTypeHeader];
    }
    
    [self appendASCIIString:@"\r\n"];
}

- (void)appendASCIIString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [self appendData:data];
}

- (void)appendData:(NSData *)data
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
        [self.outputStream write:buffer maxLength:size];
    }
}

- (void)finishWriting
{
    dispatch_sync(self.outputQueue, ^(void)
    {
        [self appendASCIIString:[NSString stringWithFormat:@"\r\n--%@--", self.boundary]];
        [self.outputStream close];
        self.outputStream = nil;
    });
}

@end
