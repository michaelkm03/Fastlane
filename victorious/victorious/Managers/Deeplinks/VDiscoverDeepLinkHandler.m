//
//  VDiscoverDeepLinkHandler.m
//  victorious
//
//  Created by Patrick Lynch on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDiscoverDeepLinkHandler.h"
#import "NSURL+VPathHelper.h"

static NSString * const kDeeplinkHost = @"discover";

@implementation VDiscoverDeepLinkHandler

- (BOOL)requiresAuthorization
{
    return NO;
}

- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        completion( NO, nil );
        return;
    }
    
    completion( YES, self.navigationDestination );
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    return [url.host isEqualToString:kDeeplinkHost];
}

@end
