//
//  VMultipartFormDataWriter.m
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMultipartFormDataWriter.h"

#import <XCTest/XCTest.h>

@interface VMultipartFormDataWriterTests : XCTestCase

@property (nonatomic, strong) VMultipartFormDataWriter *writer;
@property (nonatomic, strong) NSURL *outputFileURL;

@end

@implementation VMultipartFormDataWriterTests

- (void)setUp
{
    [super setUp];
    
    NSString *temporaryFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    self.outputFileURL = [NSURL fileURLWithPath:temporaryFilename];
    self.writer = [[VMultipartFormDataWriter alloc] initWithOutputFileURL:self.outputFileURL];
}

- (void)tearDown
{
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtURL:self.outputFileURL error:nil];
}

#pragma mark - Helpers

- (NSArray *)splitHeaders:(NSString *)headers
{
    return [headers componentsSeparatedByString:@"\r\n"];
}

- (NSArray *)splitHeader:(NSString *)header
{
    NSRange colon = [header rangeOfString:@":"];
    if ((colon.location == NSNotFound) ||
        (colon.location == header.length - 1))
    {
        return @[header, @""];
    }
    
    NSString *headerName = [header substringWithRange:NSMakeRange(0, colon.location)];
    NSString *headerContents = [header substringWithRange:NSMakeRange(colon.location + 1, colon.length - colon.location - 1)];
    
    return @[headerName, [headerContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

#pragma mark - Tests

- (void)testDefaultBoundary
{
    // Just need to test that a default exists; doesn't matter what it is
    NSString *boundary = self.writer.boundary;
    XCTAssertTrue(boundary.length > 0);
}

- (void)testContentTypeHeader
{
    NSString *correctContentTypeHeader = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", self.writer.boundary];
    NSString *actualContentTypeHeader = [self.writer contentTypeHeader];
    XCTAssertEqualObjects(correctContentTypeHeader, actualContentTypeHeader);
}

- (void)testPlaintextField
{
    NSString *plaintext = @"hello world";
    NSString *fieldName = @"f";
    NSString *expectedOutput = @"\r\n"
                               @"--boundary\r\n"
                               @"Content-Disposition: form-data; name=\"f\"\r\n"
                               @"Content-Type: text/plain; charset=UTF-8\r\n"
                               @"\r\n"
                               @"hello world"
                               @"\r\n--boundary--";
    
    self.writer.boundary = @"boundary";
    XCTAssertTrue([self.writer appendPlaintext:plaintext withFieldName:fieldName error:nil]);
    XCTAssertTrue([self.writer finishWritingWithError:nil]);
    
    NSString *actualOutput = [NSString stringWithContentsOfURL:self.outputFileURL encoding:NSASCIIStringEncoding error:nil];
    XCTAssertEqualObjects(expectedOutput, actualOutput);
}

- (void)testStream
{
    NSString *streamString = @"hello world";
    NSData *streamData = [streamString dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:streamData];
    NSString *fieldName = @"s";
    NSString *filename = @"hello.txt";
    NSString *contentType = @"text/plain";
    NSString *expectedOutput = @"\r\n"
    @"--boundary\r\n"
    @"Content-Disposition: form-data; name=\"s\"; filename=\"hello.txt\"\r\n"
    @"Content-Type: text/plain\r\n"
    @"\r\n"
    @"hello world"
    @"\r\n--boundary--";
    
    [inputStream open];
    self.writer.boundary = @"boundary";
    XCTAssertTrue([self.writer appendFileWithName:filename
                                      contentType:contentType
                                           stream:inputStream
                                        fieldName:fieldName
                                            error:nil]);
    XCTAssertTrue([self.writer finishWritingWithError:nil]);
    [inputStream close];
    
    NSString *actualOutput = [NSString stringWithContentsOfURL:self.outputFileURL encoding:NSASCIIStringEncoding error:nil];
    XCTAssertEqualObjects(expectedOutput, actualOutput);
}

- (void)testFile
{
    NSString *fieldName = @"j";
    NSString *filename = @"sample.jpg";
    NSString *contentType = @"image/jpeg";
    NSString *pre = @"\r\n"
                    @"--boundary\r\n"
                    @"Content-Disposition: form-data; name=\"j\"; filename=\"sample.jpg\"\r\n"
                    @"Content-Type: image/jpeg\r\n"
                    @"\r\n";
    NSURL *sampleFile = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"jpg"];
    NSString *post = @"\r\n--boundary--";
    
    NSMutableData *expectedOutput = [[NSMutableData alloc] init];
    [expectedOutput appendData:[pre dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    [expectedOutput appendData:[NSData dataWithContentsOfURL:sampleFile]];
    [expectedOutput appendData:[post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    self.writer.boundary = @"boundary";
    XCTAssertTrue([self.writer appendFileWithName:filename
                                      contentType:contentType
                                          fileURL:sampleFile
                                        fieldName:fieldName
                                            error:nil]);
    XCTAssertTrue([self.writer finishWritingWithError:nil]);
    
    NSData *actualOutput = [NSData dataWithContentsOfURL:self.outputFileURL];
    XCTAssertEqualObjects(expectedOutput, actualOutput);
}

@end
