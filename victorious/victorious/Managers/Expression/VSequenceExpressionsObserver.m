//
//  VSequenceExpressionsObserver.m
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequenceExpressionsObserver.h"
#import <KVOController/FBKVOController.h>
#import "VSequence.h"
#import "VSequence+Fetcher.h"

@interface VSequenceExpressionsObserver()

@property (nonatomic, strong) VSequence *sequence;

@end

@implementation VSequenceExpressionsObserver

- (void)dealloc
{
    [self stopObserving];
}

- (void)startObservingWithSequence:(VSequence *)sequence onUpdate:(void(^)())update
{
    NSParameterAssert( sequence != nil );
    NSParameterAssert( update != nil );
    
    [self stopObserving];
    
    self.sequence = sequence;
    
    [self.KVOController observe:self.sequence keyPath:NSStringFromSelector(@selector(isLikedByMainUser))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         update();
     }];
    [self.KVOController observe:self.sequence keyPath:NSStringFromSelector(@selector(likeCount))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         update();
     }];
    [self.KVOController observe:self.sequence keyPath:NSStringFromSelector(@selector(commentCount))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         update();
     }];
    
    update();
}

- (void)stopObserving
{
    [self.KVOController unobserve:self.sequence];
}

@end
