//
//  NSData+AES.m
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSData+AES.h"

#include <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>

#if TARGET_OS_IPHONE
#include <Security/SecRandom.h>
#else
#include <fcntl.h>
#include <unistd.h>
#endif

@implementation NSData(AES)

- (NSData *)encryptedDataWithAESKey:(NSData *)key
{
	uint8_t iv[kCCBlockSizeAES128];
	
	size_t retSize = 0;
	CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     [key bytes],
                                     [key length],
                                     iv,
                                     [self bytes],
                                     [self length],
                                     NULL,
                                     0,
                                     &retSize);
	if ( result != kCCBufferTooSmall )
    {
		return nil;
	}
	
	void *retPtr = malloc( retSize + sizeof(iv) );
	if ( !retPtr )
    {
		return nil;
	}
	
	// Copy the IV.
	memcpy( retPtr, iv, sizeof(iv) );
	
	result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
					 [key bytes], [key length],
					 iv,
					 [self bytes], [self length],
					 retPtr+sizeof(iv),
                     retSize,
					 &retSize);
    
	if ( result != kCCSuccess )
    {
		free( retPtr );
		return nil;
	}
	
	NSData *ret = [NSData dataWithBytesNoCopy:retPtr length:retSize + sizeof(iv) ];
	if ( !ret )
    {
		free( retPtr );
		return nil;
	}
    
	return ret;
}

- (NSData *)decryptedDataWithAESKey:(NSData *)key
{
	const uint8_t *bytesPointer = [self bytes];
	size_t length = [self length];
	if ( length < kCCBlockSizeAES128 )
    {
        return nil;
    }
	
	size_t retSize = 0;
	CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     [key bytes],
                                     [key length],
                                     bytesPointer,
                                     bytesPointer + kCCBlockSizeAES128,
                                     length-kCCBlockSizeAES128,
                                     NULL,
                                     0,
                                     &retSize);
	if (result != kCCBufferTooSmall)
    {
        return nil;
    }
	
	void *retPtr = malloc(retSize);
	if (!retPtr)
    {
        return nil;
    }
	
	result = CCCrypt(kCCDecrypt,
                     kCCAlgorithmAES128,
                     kCCOptionPKCS7Padding,
					 [key bytes],
                     [key length],
					 bytesPointer,
					 bytesPointer + kCCBlockSizeAES128,
                     length-kCCBlockSizeAES128,
					 retPtr,
                     retSize,
					 &retSize);
	if (result != kCCSuccess)
    {
        free(retPtr);
        return nil;
    }
	
	NSData *ret = [NSData dataWithBytesNoCopy:retPtr length:retSize];
	if ( !ret )
    {
        free( retPtr );
        return nil;
    }
    
	return ret;
}

@end
