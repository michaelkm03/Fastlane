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

- (void)toggleLikeWithSequence:(VSequence *)sequence completion:(void(^)(VSequence *sequence))completion
{
    if ( sequence.isLikedByMainUser.boolValue )
    {
        sequence.isLikedByMainUser = @NO;
        sequence.likeCount = @(sequence.likeCount.integerValue - 1);
    }
    else
    {
        sequence.isLikedByMainUser = @YES;
        sequence.likeCount = @(sequence.likeCount.integerValue + 1);
    }
    completion( sequence );
}

@end
