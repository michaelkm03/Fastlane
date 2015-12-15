//
//  VMockRequestRecorder.m
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VMockRequestRecorder.h"

@implementation VMockRequestRecorder

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _requestsSent = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)sendRequest:(NSURLRequest *)request
{
    [self.requestsSent addObject:request];
}

@end
