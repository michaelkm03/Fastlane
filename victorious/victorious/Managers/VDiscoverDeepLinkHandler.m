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

- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        return NO;
    }
    
    completion( nil );
    
    return YES;
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    return [url.host isEqualToString:kDeeplinkHost];
}

@end
