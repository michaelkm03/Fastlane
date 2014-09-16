//
//  VContentViewViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewViewModel.h"

// Model Categories
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VObjectManager+Comment.h"

@interface VContentViewViewModel ()

@property (nonatomic, strong, readonly) VNode *currentNode;
@property (nonatomic, strong, readwrite) VSequence *sequence;
@property (nonatomic, strong, readwrite) VAsset *currentAsset;

@end

@implementation VContentViewViewModel

#pragma mark - Initializers

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        _sequence = sequence;
        
        if ([sequence isPoll])
        {
            _type = VContentViewTypePoll;
        }
        else if ([sequence isVideo])
        {
            _type = VContentViewTypeVideo;
        }
        else if ([sequence isImage])
        {
            _type = VContentViewTypeImage;
        }
        else
        {
            _type = VContentViewTypeInvalid;
        }

        _currentAsset = [_currentNode firstAsset];
        
        [[VObjectManager sharedManager] fetchFiltedRealtimeCommentForAssetId:_currentAsset.remoteId.integerValue
                                                                successBlock:nil
                                                                   failBlock:nil];
    }
    return self;
}

- (id)init
{
    [[NSException exceptionWithName:@"Invalid initializer."
                            reason:@"-init is not allowed. Use the designate initializer: \"-initWithSequence:\""
                           userInfo:nil] raise];
    return nil;
}

#pragma mark - Property Accessors

- (NSURLRequest *)imageURLRequest
{
    NSURL* imageUrl;
    if (self.type == VContentViewTypeImage)
    {
        VAsset *currentAsset = [self.currentNode firstAsset];
        imageUrl = [NSURL URLWithString:currentAsset.data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImage];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    return request;
}

- (NSURL *)videoURL
{
    VAsset *currentAsset = [self.currentNode firstAsset];
    return [NSURL URLWithString:currentAsset.data];
}

- (BOOL)shouldShowRealTimeComents
{
    VAsset *currentAsset = [self.currentNode firstAsset];
    NSArray *realTimeComments = [currentAsset.comments array];
    return (realTimeComments.count > 0) ? YES : NO;
}

@end
