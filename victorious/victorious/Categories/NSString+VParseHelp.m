//
//  NSString+VParseHelp.m
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSString+VParseHelp.h"

@implementation NSString (VParseHelp)

- (CGSize)frameSizeForWidth:(CGFloat)width andAttributes:(NSDictionary *)attributes
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
    
    CGRect boundingRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:options
                                          attributes:attributes
                                             context:nil];
    
    return CGSizeMake(ceil(boundingRect.size.width), ceil(boundingRect.size.height));
}

- (NSURL *)mp4UrlFromM3U8
{
    if (![[self pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        return nil;
    }
    
    return [[[[[NSURL URLWithString:self] URLByDeletingLastPathComponent]
              URLByAppendingPathComponent:@"720" isDirectory:YES]
             URLByAppendingPathComponent:@"video"]
            URLByAppendingPathExtension:@"mp4"];
}

- (BOOL)isEmpty
{
    return [self isEmptyWithCleanWhiteSpace:YES];
}

- (BOOL)isEmptyWithCleanWhiteSpace:(BOOL)cleanWhileSpace
{
    if ([self length] == 0)
    {
        return YES;
    }
    
    if (cleanWhileSpace)
    {
        NSString* aString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0)
        {
            return YES;
        }
    }
    
    return NO;  
}

@end
