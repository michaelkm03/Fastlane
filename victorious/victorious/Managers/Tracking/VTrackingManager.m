//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"

@interface VTrackingManager ()

@property (nonatomic, strong) NSMutableArray *delegates;

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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _delegates = [[NSMutableArray alloc] init];
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
        [self deallocateSharedInstance];
    }
}

- (void)removeAllServices
{
    [self.delegates removeAllObjects];
    [self deallocateSharedInstance];
}

- (void)deallocateSharedInstance
{
    _sharedInstance = nil;
}

@end
