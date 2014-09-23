//
//  VContentViewViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewViewModel.h"

// Models
#import "VComment.h"
#import "VUser.h"

// Model Categories
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VObjectManager+Comment.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+ContentCreation.h"
#import "VComment+Fetcher.h"

// Formatters
#import "NSDate+timeSince.h"
#import "VRTCUserPostedAtFormatter.h"

// Media
#import "NSURL+MediaType.h"

NSString * const VContentViewViewModelDidUpdateCommentsNotification = @"VContentViewViewModelDidUpdateCommentsNotification";
NSString * const VContentViewViewModelDidUpdateRealTimeCommentsNotification = @"VContentViewViewModelDidUpdateRealTimeCommentsNotification";

@interface VContentViewViewModel ()

@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong, readonly) VNode *currentNode;
@property (nonatomic, strong, readwrite) VSequence *sequence;
@property (nonatomic, strong, readwrite) VAsset *currentAsset;
@property (nonatomic, strong, readwrite) VRealtimeCommentsViewModel *realTimeCommentsViewModel;

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
            _realTimeCommentsViewModel = [[VRealtimeCommentsViewModel alloc] init];
        }
        else if ([sequence isImage])
        {
            _type = VContentViewTypeImage;
        }
        else
        {
            _type = VContentViewTypeInvalid;
        }

        _currentNode = [sequence firstNode];
        _currentAsset = [_currentNode.assets firstObject];
        
    }
    return self;
}

- (id)init
{
    NSAssert(false, @"-init is not allowed. Use the designate initializer: \"-initWithSequence:\"");
    return nil;
}

#pragma mark - Property Accessors

- (NSURLRequest *)imageURLRequest
{
    NSURL *imageUrl;
    if (self.type == VContentViewTypeImage)
    {
        VAsset *currentAsset = [_currentNode.assets firstObject];
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

- (NSString *)name
{
    return self.sequence.name;
}

- (NSURL *)videoURL
{
    VAsset *currentAsset = [_currentNode.assets firstObject];
    return [NSURL URLWithString:currentAsset.data];
}

- (BOOL)shouldShowRealTimeComents
{
    VAsset *currentAsset = [_currentNode.assets firstObject];
    NSArray *realTimeComments = [currentAsset.comments array];
    return (realTimeComments.count > 0) ? YES : NO;
}

- (NSArray *)comments
{
    NSArray *comments = [self.sequence.comments sortedArrayUsingComparator:^NSComparisonResult(VComment *comment1, VComment *comment2)
     {
         NSComparisonResult result = [comment1.postedAt compare:comment2.postedAt];
         switch (result)
         {
             case NSOrderedAscending:
                 return NSOrderedDescending;
             case NSOrderedSame:
                 return NSOrderedSame;
             case NSOrderedDescending:
                 return NSOrderedAscending;
         }
    }];

    _comments = [NSArray arrayWithArray:_comments];
    return comments;
}

- (NSInteger)commentCount
{
    return (NSInteger)self.comments.count;
}

#pragma mark - Public Methods

- (void)addCommentWithText:(NSString *)text
                  mediaURL:(NSURL *)mediaURL
                completion:(void (^)(BOOL succeeded))completion
{
    Float64 currentTime = CMTimeGetSeconds(self.realTimeCommentsViewModel.currentTime);
    if (isnan(currentTime))
    {
        [[VObjectManager sharedManager] addCommentWithText:text
                                                  mediaURL:mediaURL
                                                toSequence:self.sequence
                                                 andParent:nil
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             if (completion)
             {
                 completion(YES);
             }
         }
                                                 failBlock:^(NSOperation *operation, NSError *error)
         {
             if (completion)
             {
                 completion(NO);
             }
         }];
    }
    else
    {
        [[VObjectManager sharedManager] addRealtimeCommentWithText:text
                                                          mediaURL:mediaURL
                                                           toAsset:self.currentAsset
                                                            atTime:@(CMTimeGetSeconds(self.realTimeCommentsViewModel.currentTime))
                                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             if (completion)
             {
                 completion(YES);
             }
         }
                                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             if (completion)
             {
                 completion(NO);
             }
         }];
    }
}

- (void)fetchComments
{
    [[VObjectManager sharedManager] fetchFiltedRealtimeCommentForAssetId:_currentAsset.remoteId.integerValue
                                                            successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         // Ensure we have all VComments
         [resultObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
          {
              if (![obj isKindOfClass:[VComment class]])
              {
                  return;
              }
          }];
         
         self.realTimeCommentsViewModel.realTimeComments = [self.sequence.comments array];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:VContentViewViewModelDidUpdateRealTimeCommentsNotification
                                                             object:self];
     }
                                                               failBlock:nil];
    
    [[VObjectManager sharedManager] loadCommentsOnSequence:self.sequence
                                                 isRefresh:NO
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:VContentViewViewModelDidUpdateCommentsNotification
                                                             object:self];
     }
                                                 failBlock:nil];
}

- (NSString *)commentBodyForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return commentForIndex.text;
}

- (NSString *)commenterNameForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return commentForIndex.user.name;
}

- (NSString *)commentTimeAgoTextForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return [commentForIndex.postedAt timeSince];
}

- (NSString *)commentRealTimeCommentTextForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    if (commentForIndex.realtime.floatValue < 0)
    {
        return @"";
    }
    
    return [[VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:nil
                                                                   andPostedTime:commentForIndex.realtime] string];
}

- (NSURL *)commenterAvatarURLForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return [NSURL URLWithString:commentForIndex.user.pictureUrl];
}

- (BOOL)commentHasMediaForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return commentForIndex.hasMedia;
}

- (NSURL *)commentMediaPreviewUrlForCommentIndex:(NSInteger)commentIndex
{
    if (![self commentHasMediaForCommentIndex:commentIndex])
    {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"No media for comment index: %@", @(commentIndex)]
                               userInfo:nil] raise];
    }
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return commentForIndex.previewImageURL;
}

- (NSURL *)mediaURLForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return [NSURL URLWithString:commentForIndex.mediaUrl];
}

- (BOOL)commentMediaIsVideoForCommentIndex:(NSInteger)commentIndex
{
    if (![self commentHasMediaForCommentIndex:commentIndex])
    {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"No media for comment index: %@", @(commentIndex)]
                               userInfo:nil] raise];
    }
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return ([commentForIndex.mediaUrl isKindOfClass:[NSString class]] && [commentForIndex.mediaUrl v_hasVideoExtension]);
}

@end
