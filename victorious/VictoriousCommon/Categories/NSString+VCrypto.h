//
//  NSString+VCrypto.h
//  victorious
//
//  Created by Josh Hinman on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A category for performing cryptographic operations on strings
 */
@interface NSString (VCrypto)

/**
 Returns a SHA-256 hash of the receiver
 */
- (NSString *)v_sha256;

@end
