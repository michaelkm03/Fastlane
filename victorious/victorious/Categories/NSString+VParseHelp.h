//
//  NSString+VParseHelp.h
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VConstants.h"

@interface NSString (VParseHelp)

@property (nonatomic, readonly, getter = typeByExtension) NSString* extensionType;

- (CGSize)frameSizeForWidth:(CGFloat)width andAttributes:(NSDictionary*)attributes;

- (NSURL*)mp4UrlFromM3U8;

- (BOOL) isEmpty;
- (BOOL) isEmptyWithCleanWhiteSpace:(BOOL)cleanWhileSpace;

@end
