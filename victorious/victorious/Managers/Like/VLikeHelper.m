//
//  VLikeHelper.m
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikeHelper.h"
#import "VSequence.h"

@implementation VLikeHelper

- (void)likeSequence:(VSequence *)sequence completion:(void(^)(VSequence *sequence))completion
{
    completion( sequence );
}

- (void)unlikeSequence:(VSequence *)sequence completion:(void(^)(VSequence *sequence))completion
{
    completion( sequence );
}

@end
