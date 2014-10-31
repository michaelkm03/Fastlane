//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VTrackingQueue.h"
#import "VTrackingEvent.h"

@interface VTrackingManager ()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) VTrackingQueue *queue;

@end

static VTrackingManager *_sharedInstance;

@implementation VTrackingManager

+ (VTrackingManager *)sharedInstance
{
    if ( _sharedInstance == nil )
    {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (void)deallocateSharedInstance
{
    _sharedInstance = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _delegates = [[NSMutableArray alloc] init];
        _queue = [[VTrackingQueue alloc] init];
    }
    return self;
}

- (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
     {
         [delegate trackEventWithName:eventName withParameters:parameters];
     }];
}

- (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName withParameters:nil];
}

- (void)addDelegate:(id<VTrackingDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void)removeService:(id<VTrackingDelegate>)delegate
{
    [self.delegates removeObject:delegate];
    
    if ( self.delegates.count == 0 )
    {
        [VTrackingManager deallocateSharedInstance];
    }
}

- (void)removeAllServices
{
    [self.delegates removeAllObjects];
    
    [VTrackingManager deallocateSharedInstance];
}

@end
