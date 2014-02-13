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

- (CGFloat)heightForViewWidth:(CGFloat)width andAttributes:(NSDictionary*)attributes;

- (NSString*)previewImageURLForM3U8;

- (BOOL ) isEmpty;
- (BOOL ) isEmptyWithCleanWhiteSpace:(BOOL)cleanWhileSpace;

@end
