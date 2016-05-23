//
//  VVideoPlayer.h
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoPlayer.h"

@implementation VVideoPlayerItem

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self != nil)
    {
        _url = url;
    }
    return self;
}

- (instancetype)initWithExternalID:(NSString *)externalID
{
    self = [super init];
    if (self != nil)
    {
        _remoteContentId = externalID;
    }
    return self;
}

@end
