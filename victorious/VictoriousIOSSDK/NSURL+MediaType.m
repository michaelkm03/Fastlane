//
//  NSURL+MediaType.m
//  victorious
//
//  Created by Josh Hinman on 5/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VConstants.h"

static inline BOOL isExtensionMp4(NSString *pathExtension)
{
    NSString *lowercasePathExtension = [pathExtension lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    return [lowercasePathExtension isEqualToString:VConstantMediaExtensionMP4];
}

static inline BOOL isVideoExtension(NSString *pathExtension)
{
    NSString *lowercasePathExtension = [pathExtension lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    return [lowercasePathExtension isEqualToString:VConstantMediaExtensionM3U8] ||
            [lowercasePathExtension isEqualToString:VConstantMediaExtensionMP4] ||
            [lowercasePathExtension isEqualToString:VConstantMediaExtensionMOV];
}

static inline BOOL isGIFExtension(NSString *pathExtension)
{
    NSString *lowercasePathExtension = [pathExtension lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    return [lowercasePathExtension isEqualToString:VConstantMediaExtensionM3U8] ||
    [lowercasePathExtension isEqualToString:VConstantMediaExtensionMP4] ||
    [lowercasePathExtension isEqualToString:VConstantMediaExtensionMOV];
}

static inline BOOL isImageExtension(NSString *pathExtension)
{
    NSString *lowercasePathExtension = [pathExtension lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    return [lowercasePathExtension isEqualToString:VConstantMediaExtensionGIF];
}

@implementation NSURL (MediaType)

- (BOOL)v_hasVideoExtension
{
    return isVideoExtension([self pathExtension]);
}

- (BOOL)v_hasImageExtension
{
    return isImageExtension([self pathExtension]);
}

- (BOOL)v_hasGIFExtension
{
    return isGIFExtension([self pathExtension]);
}

@end

@implementation NSString (MediaType)

- (BOOL)v_hasVideoExtension
{
    return isVideoExtension([self pathExtension]);
}

- (BOOL)v_hasImageExtension
{
    return isImageExtension([self pathExtension]);
}

- (BOOL)v_hasGIFExtension
{
    return isGIFExtension([self pathExtension]);
}

- (BOOL)v_isExtensionMp4
{
    return isExtensionMp4([self pathExtension]);
}

@end
