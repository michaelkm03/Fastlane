//
//  NSString+VParseHelp.m
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSString+VParseHelp.h"

@implementation NSString (VParseHelp)

- (CGFloat)heightForViewWidth:(CGFloat)width andAttributes:(NSDictionary*)attributes
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    
    width -= 40; //There seems to be an issue with rect this function returns.  Multiple people this -40 on the width is the "magic number" to fix it.  Worse case, this makes the bounding box a little big instead.  Link to SO: http://stackoverflow.com/questions/19398674/sizewithfont-method-is-deprecated-boundingrectwithsize-is-returning-wrong-value
    
    CGRect boundingRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:options
                                          attributes:attributes
                                             context:nil];
    
    return (CGFloat) (ceil(boundingRect.size.height));
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
