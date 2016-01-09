//
//  VSDKCrypto.h
//  victorious
//
//  Created by Josh Hinman on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Returns a SHA1 hash of the given string
 */
extern NSString *vsdk_sha1(NSString *plaintext);

/**
 Returns a SHA256 hash of the given string
 */
extern NSString *vsdk_sha256(NSString *plaintext);

NS_ASSUME_NONNULL_END
