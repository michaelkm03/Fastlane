//
//  VComment+Fetcher.m
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment+Fetcher.h"
#import "NSString+VParseHelp.h"

@implementation VComment (Fetcher)

- (BOOL)hasMedia
{
    return (self.mediaUrl && ![self.mediaUrl isEmpty]) || (self.thumbnailUrl && ![self.thumbnailUrl isEmpty]);
}

- (NSURL *)previewImageURL
{
    NSURL *url;
    if (self.thumbnailUrl && ![self.thumbnailUrl isEmpty])
    {
        url = [[NSURL alloc] initWithString:self.thumbnailUrl];
    }
    else if (self.mediaUrl && ![self.mediaUrl isEmpty] && [self.mediaType isEqualToString:VConstantsMediaTypeImage])
    {
        url = [[NSURL alloc] initWithString:self.thumbnailUrl];
    }

    return url;
}

@end
