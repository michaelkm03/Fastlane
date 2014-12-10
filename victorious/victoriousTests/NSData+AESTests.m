//
//  NSData+AESTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSData+AES.h"

@interface NSData_AESTests : XCTestCase

@end

@implementation NSData_AESTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEncryption
{
	NSString *myData = @"{ \"something\" : \"value\" }";
	NSData *key = [@"my_symmetric_key" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [myData dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encrypedData = [data encryptedDataWithAESKey:key];
	
	NSString *encrptedString = [[NSString alloc] initWithData:encrypedData encoding:NSStringEncodingConversionExternalRepresentation];
	NSLog( @"encryptedString = %@", encrptedString );
	
	XCTAssertNotNil( encrypedData, @"Encryption failed." );
	XCTAssertTrue( encrypedData.length > 0, @"Encryption failed." );
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ).firstObject;
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:@"test_encryption"];
    [encrypedData writeToFile:filepath atomically:YES];
	
	NSData *readEncryptedData = [NSData dataWithContentsOfFile:filepath];
	NSData *decryptedData = [readEncryptedData decryptedDataWithAESKey:key];
	
	XCTAssertNotNil( decryptedData, @"Decryption failed." );
	XCTAssertTrue( decryptedData.length > 0, @"Decryption failed." );
	
	NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
	NSLog( @"decryptedString = %@", decryptedString );
}

@end
