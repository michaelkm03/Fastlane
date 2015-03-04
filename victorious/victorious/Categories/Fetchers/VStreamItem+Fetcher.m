//
//  VStreamItem+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem+Fetcher.h"

static NSString * const kVSequenceContentType = @"sequence";
static NSString * const kVStreamContentTypeContent = @"content";
static NSString * const kVStreamContentTypeStream = @"stream";

@implementation VStreamItem (Fetcher)

- (BOOL)isContent
{
    return self.streamContentType == nil;
}

- (BOOL)isSingleStream
{
    return [self.streamContentType isEqualToString:kVStreamContentTypeContent];
}

- (BOOL)isStreamOfStreams
{
    return [self.streamContentType isEqualToString:kVStreamContentTypeStream];
}

- (NSArray *)previewImagePaths
{
    if ([self.previewImagesObject isKindOfClass:[NSArray class]] || !self.previewImagesObject)
    {
        return self.previewImagesObject;
    }
    else if ([self.previewImagesObject isKindOfClass:[NSString class]])
    {
        return @[self.previewImagesObject];
    }
    else
    {
        NSAssert(false, @"undefined type for sequence.previewImage");
        return nil;
    }
}

@end
