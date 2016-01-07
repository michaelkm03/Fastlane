//
//  NSString+VParseHelp.m
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSString+VParseHelp.h"
@import VictoriousIOSSDK;

@implementation NSString (VParseHelp)

- (CGSize)frameSizeForWidth:(CGFloat)width andAttributes:(NSDictionary *)attributes
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
    
    CGRect boundingRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:options
                                          attributes:attributes
                                             context:nil];
    
    return CGSizeMake(VCEIL((boundingRect.size.width)), VCEIL(boundingRect.size.height));
}

- (NSURL *)mp4UrlFromM3U8
{
    if ([[self pathExtension] isEqualToString:VConstantMediaExtensionMP4])
    {
        return [NSURL URLWithString:self];
    }
    
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
        NSString *aString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0)
        {
            return YES;
        }
    }
    
    return NO;  
}

- (NSString *)v_pathComponent
{
    // We must percent encode the macros in our path otherwise NSURLComponents will return nil
    NSString *percentEncoded = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet vsdk_pathPartCharacterSet]];
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:percentEncoded];
    return components.path;
}

@end
