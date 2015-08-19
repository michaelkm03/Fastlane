//
//  VUser+Fetcher.m
//  victorious
//
//  Created by Michael Sena on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUser+Fetcher.h"
#import "VHashtag.h"

@implementation VUser (Fetcher)

- (BOOL)shouldSkipTrimmer
{
    NSInteger trimmerDuration = [self.maxUploadDuration integerValue];
    return (trimmerDuration > 15);
}

- (BOOL)isFollowingHashtagString:(NSString *)hashtag
{
    for (VHashtag *tag in self.hashtags)
    {
        if ([tag.tag isEqualToString:hashtag])
        {
            return YES;
        }
    }
    return NO;
}

@end
