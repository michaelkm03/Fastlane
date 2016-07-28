//
//  NSData+AES.h
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(AES)

/**
 Returns data encrypted using AES 128 algorithm.
 @param key A 16-byte symmetric encryption key.  The easiest way to create this is to
 generate a 16-character NSString and use `dataWithEncoding:` with NSUTF8StringEncoding
 to generated an NSData type.
 */
- (NSData *)encryptedDataWithAESKey:(NSData *)key;

/**
 Returns data deencrypted using AES 128 algorithm.
 @param key The same 16-byte symmetric encryption key that was used to encrypt the data.
 See `encryptDataUsingAESWithKey:` for more info on key generation.
 */
- (NSData *)decryptedDataWithAESKey:(NSData *)key;

@end
