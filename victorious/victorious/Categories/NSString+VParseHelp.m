//
//  NSString+VParseHelp.m
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSString+VParseHelp.h"

@implementation NSString (VParseHelp)

- (CGSize)frameSizeForWidth:(CGFloat)width andAttributes:(NSDictionary*)attributes
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    
    CGRect boundingRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:options
                                          attributes:attributes
                                             context:nil];
    
    return (CGSize) CGSizeMake(ceil(boundingRect.size.width), ceil(boundingRect.size.height));
}

- (NSString*)typeByExtension
{
    if ([[self pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
        return VConstantsMediaTypeVideo;
    
    if ([[self pathExtension] isEqualToString:VConstantMediaExtensionM3U8]
        || [[self pathExtension] isEqualToString:VConstantMediaExtensionPNG]
        || [[self pathExtension] isEqualToString:VConstantMediaExtensionJPEG]
        || [[self pathExtension] isEqualToString:VConstantMediaExtensionJPG])
        return VConstantsMediaTypeImage;
    
    return nil;
}

- (NSURL*)convertToPreviewImageURL
{
    if ([[self pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
        [NSURL URLWithString:[self previewImageURLForM3U8]];

    return [NSURL URLWithString:self];
}

- (NSString*)previewImageURLForM3U8
{
    //    $basename . '/playlist.m3u8';
    //    $basename . '/thumbnail-00001.png';
    return  [[[self stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"thumbnail-00001"] stringByAppendingPathExtension: @"png"];
}

- (BOOL ) isEmpty
{
    return [self isEmptyWithCleanWhiteSpace:YES];
}

- (BOOL ) isEmptyWithCleanWhiteSpace:(BOOL)cleanWhileSpace
{
    
    if ((NSNull *) self == [NSNull null]) {
        return YES;
    }
    
    if (self == nil) {
        return YES;
    } else if ([self length] == 0) {
        return YES;
    }
    
    if (cleanWhileSpace) {
        NSString* aString = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;  
}

@end
