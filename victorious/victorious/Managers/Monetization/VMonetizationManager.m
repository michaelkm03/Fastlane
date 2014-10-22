//
//  VMonetizationManager.m
//  victorious
//
//  Created by Lawrence Leach on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMonetizationManager.h"
#import "VSequence.h"

@interface VMonetizationManager ()

@property (nonatomic, strong) NSDictionary *adObjects;

@end

@implementation VMonetizationManager

- (id)init
{
    return [self initWithSequenceObject:nil];
}

- (instancetype)initWithSequenceObject:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        _sequence = sequence;
    }
    return self;
}

#pragma mark - Sequence

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    if ([sequence.category isEqualToString:@"owner_video"])
    {
        //NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        //id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]
    }
}

#pragma mark - Ad Manager

- (void)startMonetizationManager
{
    
}

#pragma mark - VAdVideoPlayerViewControllerDelegate

- (void)adDidFinishInVAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    
}

- (void)adIsLoaded:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    
}

- (void)adHasImpression:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    
}

- (void)adHadAnError:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayerViewController
      didPlayToTime:(CMTime)time
{
    
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayerViewController
{
    
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayerViewController
{
    
}

@end
