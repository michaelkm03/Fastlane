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
#import "VAsset.h"
#import "VAnswer.h"
#import "VPollResult.h"
#import "VVoteType.h"
#import "VNode+Fetcher.h"

// Model Categories
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VObjectManager+Comment.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+ContentCreation.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VComment+Fetcher.h"
#import "VUser.h"
#import "VPaginationManager.h"
#import "VAsset+VCachedData.h"

// Formatters
#import "NSDate+timeSince.h"
#import "VRTCUserPostedAtFormatter.h"
#import "NSString+VParseHelp.h"
#import "VLargeNumberFormatter.h"

// Media
#import "NSURL+MediaType.h"
#import "VAsset+VAssetCache.h"

// Monetization
#import "VAdBreak.h"
#import "VAdBreakFallback.h"

// End Card
#import "VEndCard.h"
#import "VStream.h"
#import "VEndCardModel.h"
#import "VDependencyManager.h"
#import "VVideoSettings.h"
#import "UIColor+VHex.h"
#import "VEndCardModelBuilder.h"
#import "victorious-Swift.h"

#import "VObjectManager+ContentModeration.h"

@interface VContentViewViewModel ()

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong, readwrite) VAsset *currentAsset;
@property (nonatomic, strong, readwrite) VRealtimeCommentsViewModel *realTimeCommentsViewModel;
@property (nonatomic, strong, readwrite) VExperienceEnhancerController *experienceEnhancerController;
@property (nonatomic, strong, readwrite) ContentViewContext *context;

@property (nonatomic, strong) NSString *followersText;

@property (nonatomic, strong) NSMutableArray *adChain;
@property (nonatomic, assign, readwrite) NSInteger currentAdChainIndex;
@property (nonatomic, assign, readwrite) VMonetizationPartner monetizationPartner;
@property (nonatomic, assign, readwrite) NSArray *monetizationDetails;
@property (nonatomic, assign, readwrite) VPollAnswer favoredAnswer;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, strong) AppTimingContentHelper *appTimingHelper;

@end

@implementation VContentViewViewModel

#pragma mark - Initializers

- (instancetype)initWithContext:(ContentViewContext *)context
{
    self = [super init];
    if ( self != nil )
    {
        _context = context;
        
        _sequence = context.sequence;
        _streamId = context.streamId ?: @"";
        _dependencyManager = context.destinationDependencyManager;
        
        id<TimingTracker> timingTracker = [DefaultTimingTracker sharedInstance];
        _appTimingHelper = [[AppTimingContentHelper alloc] initWithTimingTracker:timingTracker];
        
        NSDictionary *configuration = @{ @"sequence" : _sequence };
        VDependencyManager *childDependencyManager = [_dependencyManager childDependencyManagerWithAddedConfiguration:configuration];
        _experienceEnhancerController = [[VExperienceEnhancerController alloc] initWithDependencyManager:childDependencyManager];
        
        _currentNode = [_sequence firstNode];
        
        if ([_sequence isPoll])
        {
            _type = VContentViewTypePoll;
        }
        else if ([_sequence isVideo] && ![_sequence isGIFVideo])
        {
            _type = VContentViewTypeVideo;
            _realTimeCommentsViewModel = [[VRealtimeCommentsViewModel alloc] init];
            _currentAsset = [_currentNode httpLiveStreamingAsset];
        }
        else if ([_sequence isGIFVideo])
        {
            _type = VContentViewTypeGIFVideo;
            _currentAsset = [_currentNode mp4Asset];
        }
        else if ([_sequence isImage])
        {
            _type = VContentViewTypeImage;
            _currentAsset = [self mediaAssetFromSequence:_sequence];
        }
        else if ( [_sequence isText] )
        {
            _type = VContentViewTypeText;
            _currentAsset = [_currentNode textAsset];
        }
        else
        {
            // Fall back to image.
            _type = VContentViewTypeImage;
            _currentAsset = [self mediaAssetFromSequence:_sequence];
        }
        
        _hasReposted = [_sequence.hasReposted boolValue];
        
        if ( _currentAsset == nil )
        {
            _currentAsset = [_currentNode imageAsset];
        }
        
        // Set the default ad chain index
        self.currentAdChainIndex = 0;
    }
    return self;
}

- (VAsset *)mediaAssetFromSequence:(VSequence *)sequence
{
    VAsset *videoAsset = sequence.isGIFVideo ? [_currentNode mp4Asset] : [_currentNode httpLiveStreamingAsset];
    if ( videoAsset != nil )
    {
        return videoAsset;
    }
    else
    {
        return [_currentNode imageAsset];
    }
    
    return nil;
}

- (id)init
{
    NSAssert(false, @"-init is not allowed. Use the designated initializer: \"-initWithSequence:\"");
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)repost
{
    // FIXME:
    /*[[VObjectManager sharedManager] repostNode:self.currentNode
                                      withName:nil
                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         self.hasReposted = YES;
         self.sequence.repostCount = @(self.sequence.repostCount.integerValue + 1);
     }
                                     failBlock:nil];*/
}

#pragma mark - Create the ad chain

- (void)setupAdChain
{
    if ( self.adChain != nil )
    {
        return;
    }
    
    self.adChain = [[NSMutableArray alloc] init];
    NSOrderedSet *adBreakSet = self.sequence.adBreaks;
    
    for (VAdBreak *ad in adBreakSet)
    {
        NSOrderedSet *fallbackSet = ad.fallbacks;
        for (VAdBreakFallback *item in fallbackSet)
        {
            [self.adChain addObject:item];
        }
    }
    
    // Grab the preroll
    VAdBreakFallback *breakItem = [self.adChain objectAtIndex:(long)self.currentAdChainIndex];
    int adSystemPartner = [[breakItem adSystem] intValue];
    self.monetizationPartner = adSystemPartner < VMonetizationPartnerCount ? adSystemPartner : VMonetizationPartnerNone;
    self.monetizationDetails = self.adChain;
}

- (void)updateEndcard
{
    // Sets up end card
    VEndCardModelBuilder *endCardBuilder = [[VEndCardModelBuilder alloc] initWithDependencyManager:self.dependencyManager];
    self.endCardViewModel = [endCardBuilder createWithSequence:self.sequence];
}

- (void)loadNextSequenceSuccess:(void(^)(VSequence *))success failure:(void(^)(NSError *))failure
{
    NSString *nextSequenceId = self.endCardViewModel.nextSequenceId;
    if ( nextSequenceId == nil )
    {
        if ( failure != nil )
        {
            NSString *message = @"Unable to load next sequence beacuse the ID is invalid.";
            failure( [NSError errorWithDomain:message code:-1 userInfo:nil] );
        }
        return;
    }
    
    [[VObjectManager sharedManager] fetchSequenceByID:nextSequenceId
                                 inStreamWithStreamID:self.streamId
                                         successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         VSequence *nextSequence = resultObjects.firstObject;
         if ( nextSequence == nil || ![nextSequence isKindOfClass:[VSequence class]] )
         {
             if ( failure != nil )
             {
                 NSString *message = @"Response did not contain a valid sequence.";
                 failure( [NSError errorWithDomain:message code:-1 userInfo:nil] );
             }
         }
         
         if ( success != nil )
         {
             success( nextSequence );
         }
     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
         if ( failure != nil )
         {
             failure( error );
         }
     }];
}

- (void)reloadData2
{
    if (![self.sequence isPoll])
    {
        return;
    }
    [self.appTimingHelper start];

    [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                              successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [self.delegate didUpdatePollsData];
     }
                                                 failBlock:nil];
    
    if ( self.deepLinkCommentId != nil )
    {
        [self loadCommentsWithCommentId:self.deepLinkCommentId];
    }
    else
    {
        [self loadComments:VPageTypeFirst];
    }
    
    __weak typeof(self) welf = self;
    [[VObjectManager sharedManager] countOfFollowsForUser:self.user
                                             successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         NSInteger followerCount = self.user.numberOfFollowers.integerValue;
         if ( followerCount > 0 )
         {
             welf.followersText = [NSString stringWithFormat:@"%@ %@",
                                   [self.largeNumberFormatter stringForInteger:followerCount],
                                   NSLocalizedString(@"followers", @"")];
         }
         else
         {
             welf.followersText = @"";  //< To prevent showing "0 Followers"
         }
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointUserInfo];
     }
                                                failBlock:^(NSOperation *_Nullable operation, NSError *_Nullable error)
     {
         
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointUserInfo];
     }];
     
    if ( [VObjectManager sharedManager].mainUserLoggedIn )
    {
        [[VObjectManager sharedManager] fetchUserInteractionsForSequence:self.sequence
                                                          withCompletion:^(VSequenceUserInteractions *userInteractions, NSError *error)
         {
             self.hasReposted = userInteractions.hasReposted;
         }];
    }
}

- (CGSize)contentSizeWithinContainerSize:(CGSize)containerSize
{
    CGFloat maxAspect = 16.0f/9.0f;
    CGFloat minAspect = 1.0;
    CGFloat aspectRatio = CLAMP( minAspect, maxAspect, self.sequence.previewAssetAspectRatio );
    CGFloat height = containerSize.width / aspectRatio;
    return CGSizeMake( containerSize.width, height );
}

- (VLargeNumberFormatter *)largeNumberFormatter
{
    if ( _largeNumberFormatter == nil )
    {
        _largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return _largeNumberFormatter;
}

#pragma mark - Property Accessors

- (NSURLRequest *)imageURLRequest
{
    NSURL *imageUrl;
    if (self.type == VContentViewTypeImage)
    {
        imageUrl = [NSURL URLWithString:[self.sequence.firstNode imageAsset].data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImagesObject];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    return request;
}

/*
- (VAdSystem)adSystem
{
    VAdBreak *adBreak = self.sequence.adBreaks;
    NSNumber *system_type = adBreak.adSystem;
    VAdSystem ad_system = [system_type intValue];
    return ad_system;
}
*/

- (VUser *)user
{
    return self.sequence.user;
}

- (NSString *)name
{
    return self.sequence.name;
}

- (BOOL)shouldShowTitle
{
    BOOL isPollOrnameEmbedded = ([self.sequence.nameEmbeddedInContent boolValue]) || ([self.sequence isPoll]);
    return !isPollOrnameEmbedded;
}

- (NSURL *)videoURL
{
    // Check for the cached mp4
    VAsset *mp4Asset = [self.currentNode mp4Asset];
    NSURL *cacheURL = [mp4Asset cacheURLForAsset];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path])
    {
        VLog(@"cache hit!");
        return cacheURL;
    }
    
    if ([self loop])
    {
        return [NSURL URLWithString:mp4Asset.data];
    }
    else
    {
        return [NSURL URLWithString:self.currentAsset.data];
    }
}

- (float)speed
{
    return [self.currentAsset.speed floatValue];
}

- (BOOL)loop
{
    return [self.currentAsset.loop boolValue];
}

- (BOOL)playerControlsDisabled
{
    return [self.currentAsset.playerControlsDisabled boolValue];
}

- (BOOL)audioMuted
{
    return [self.currentAsset.audioMuted boolValue];
}

- (NSString *)textContent
{
    return self.currentAsset.data;
}

- (UIColor *)textBackgroundColor
{
    return [UIColor v_colorFromHexString:self.currentAsset.backgroundColor];
}

- (NSURL *)textBackgroundImageURL
{
    VAsset *imageAsset = [self.sequence.firstNode imageAsset];
    return [NSURL URLWithString:imageAsset.data];
}

- (void)setComments:(NSArray *)comments
{
    comments = [[VObjectManager sharedManager] commentsAfterStrippingFlaggedItems:comments];
    NSArray *sortedComments = [comments sortedArrayUsingComparator:^NSComparisonResult(VComment *comment1, VComment *comment2)
     {
         return [comment2.postedAt compare:comment1.postedAt];
     }];
    _comments = sortedComments;
}

#pragma mark - Public Methods

- (void)removeCommentAtIndex:(NSUInteger)index
{
    NSMutableArray *updatedComments = [self.comments mutableCopy];
    [updatedComments removeObjectAtIndex:index];
    self.comments = [NSArray arrayWithArray:updatedComments];
    [self.delegate didUpdateCommentsWithPageType:VPageTypeFirst];
}

- (void)addCommentWithText:(NSString *)text
         publishParameters:(VPublishParameters *)publishParameters
               currentTime:(Float64)currentTime
                completion:(void (^)(BOOL succeeded))completion
{
    __weak typeof(self) weakSelf = self;
    [[VObjectManager sharedManager] addRealtimeCommentWithText:text
                                             publishParameters:publishParameters
                                                       toAsset:self.currentAsset
                                                        atTime:@(currentTime)
                                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.comments = [strongSelf.sequence.comments array];
         [strongSelf.delegate didUpdateCommentsWithPageType:VPageTypeFirst];
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

- (void)addCommentWidhText:(NSString *)text
         publishParameters:(VPublishParameters *)publishParameters
                completion:(void (^)(BOOL succeeded))completion
{
    __weak typeof(self) weakSelf = self;
    [[VObjectManager sharedManager] addCommentWithText:text
                                     publishParameters:publishParameters
                                            toSequence:self.sequence
                                             andParent:nil
                                          successBlock:^(NSOperation *_Nullable operation, id  _Nullable result, NSArray *_Nonnull resultObjects)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.comments = [strongSelf.sequence.comments array];
         [strongSelf.delegate didUpdateCommentsWithPageType:VPageTypeFirst];
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

- (void)loadCommentsWithCommentId:(NSNumber *)commentId
{
    __weak typeof(self) weakSelf = self;
    [[VObjectManager sharedManager] findCommentPageOnSequence:self.sequence
                                                withCommentId:self.deepLinkCommentId
                                                 successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.comments = [strongSelf.sequence.comments array];
         [strongSelf.delegate didUpdateCommentsWithDeepLink:commentId];
         
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointComments];
     }
                                                    failBlock:^(NSOperation *_Nullable operation, NSError *_Nullable error)
     {
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointComments];
     }];
}

- (void)loadComments:(VPageType)pageType
{
    VAbstractFilter *filter = [[VObjectManager sharedManager] commentsFilterForSequence:self.sequence];
    const BOOL isFilterAlreadyLoading = [[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter];
    if ( isFilterAlreadyLoading || ![filter canLoadPageType:pageType] )
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[VObjectManager sharedManager] loadCommentsOnSequence:self.sequence
                                                  pageType:pageType
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.comments = [strongSelf.sequence.comments array];
         [strongSelf.delegate didUpdateCommentsWithPageType:pageType];
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointComments];
     }
                                                 failBlock:^(NSOperation *_Nullable operation, NSError *_Nullable error)
     {
         [self.appTimingHelper setEndpointFinished:ContentViewEndpointComments];
     }];
}

- (NSString *)commentTimeAgoTextForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return [commentForIndex.postedAt timeSince];
}

- (VUser *)userForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return commentForIndex.user;
}

- (NSString *)authorName
{
    return self.sequence.user.name;
}

- (NSString *)analyticsContentTypeText
{
    return self.sequence.category;
}

- (NSURL *)sourceURLForCurrentAssetData
{
    return [self.currentAsset.data mp4UrlFromM3U8];
}

- (NSURL *)shareURL
{
    return [NSURL URLWithString:self.currentNode.shareUrlPath] ?: nil;
}

- (NSInteger)nodeID
{
    return [self.currentNode.remoteId integerValue];
}

- (NSString *)authorCaption
{
    if (self.followersText)
    {
        return self.followersText;
    }
    return nil;
}

- (NSURL *)avatarForAuthor
{
    return [NSURL URLWithString:self.sequence.user.pictureUrl];
}

- (NSString *)memeCountText
{
    return [NSString stringWithFormat:@"%@", self.sequence.memeCount];
}

- (NSString *)gifCountText
{
    return [NSString stringWithFormat:@"%@", self.sequence.gifCount];
}

- (NSString *)repostCountText
{
    return [NSString stringWithFormat:@"%@", self.sequence.repostCount];
}

- (NSString *)shareCountText
{
    return nil;
}

- (NSURL *)mediaURLForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.comments objectAtIndex:commentIndex];
    return [NSURL URLWithString:commentForIndex.mediaUrl];
}

- (VAnswer *)answerA
{
    return ((VAnswer *)[[[self.sequence firstNode] firstAnswers] firstObject]);
}

- (VAnswer *)answerB
{
    return ((VAnswer *)[[[self.sequence firstNode] firstAnswers] lastObject]);
}

- (NSString *)answerALabelText
{
    return [self answerA].label ?: @"";
}

- (NSString *)answerBLabelText
{
    return [self answerB].label ?: @"";
}

- (NSURL *)answerAThumbnailMediaURL
{
    return [self answerAIsVideo] ? [NSURL URLWithString:[self answerA].thumbnailUrl] : [NSURL URLWithString:((VAnswer *)[[[self.sequence firstNode] firstAnswers] firstObject]).mediaUrl];
}

- (NSURL *)answerBThumbnailMediaURL
{
    return [self answerBIsVideo] ? [NSURL URLWithString:[self answerB].thumbnailUrl] : [NSURL URLWithString:((VAnswer *)[[[self.sequence firstNode] firstAnswers] lastObject]).mediaUrl];
}

- (BOOL)answerAIsVideo
{
    return [[self answerA].mediaUrl v_hasVideoExtension];
}

- (BOOL)answerBIsVideo
{
    return [[self answerB].mediaUrl v_hasVideoExtension];
}

- (NSURL *)answerAVideoUrl
{
    return [NSURL URLWithString:[self answerA].mediaUrl];
}

- (NSURL *)answerBVideoUrl
{
    return [NSURL URLWithString:[self answerB].mediaUrl];
}

- (BOOL)votingEnabled
{
    for (VPollResult *result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToString:self.sequence.remoteId])
        {
            return NO;
        }
    }
    return YES;
}

- (CGFloat)answerAPercentage
{
    if ([self totalVotes] > 0)
    {
        return (CGFloat) [self answerAResult].count.doubleValue / [self totalVotes];
    }
    return 0.0f;
}

- (CGFloat)answerBPercentage
{
    if ([self totalVotes] > 0)
    {
        return (CGFloat) [self answerBResult].count.doubleValue / [self totalVotes];
    }
    return 0.0f;
}

- (VPollResult *)answerAResult
{
    if ([self answerA].remoteId == nil)
    {
        return nil;
    }
    
    for (VPollResult *result in self.sequence.pollResults.allObjects)
    {
        if ([result.answerId isEqualToNumber:[self answerA].remoteId])
        {
            return result;
        }
    }
    return nil;
}

- (VPollResult *)answerBResult
{
    if ([self answerB].remoteId == nil)
    {
        return nil;
    }
    
    for (VPollResult *result in self.sequence.pollResults.allObjects)
    {
        if ([result.answerId isEqualToNumber:[self answerB].remoteId])
        {
            return result;
        }
    }
    return nil;
}

- (NSInteger)totalVotes
{
    NSInteger totalVotes = 0;
    for (VPollResult *pollResult in self.sequence.pollResults)
    {
        totalVotes = totalVotes + [pollResult.count integerValue];
    }

    return totalVotes;
}

- (VPollAnswer)favoredAnswer
{
    if (_favoredAnswer != VPollAnswerInvalid)
    {
        return _favoredAnswer;
    }
    else
    {
        for (VPollResult *result in [VObjectManager sharedManager].mainUser.pollResults)
        {
            NSNumber *answerARemoteID = [self answerA].remoteId;
            if ([result.sequenceId isEqualToString:self.sequence.remoteId] && answerARemoteID != nil)
            {
                _favoredAnswer = [result.answerId isEqualToNumber:answerARemoteID] ? VPollAnswerA : VPollAnswerB;
                break;
            }
        }
        return _favoredAnswer;
    }
}

- (void)answerPollWithAnswer:(VPollAnswer)selectedAnswer
                  completion:(void (^)(BOOL succeeded, NSError *error))completion
{
    [[VObjectManager sharedManager] answerPoll:self.sequence
                                    withAnswer:(selectedAnswer == VPollAnswerA) ? [self answerA] : [self answerB]
                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self.delegate didUpdatePollsData];
         
         NSDictionary *params = @{ VTrackingKeyIndex : selectedAnswer == VPollAnswerB ? @1 : @0 };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollAnswer parameters:params];
         
         completion(YES, nil);
     }
                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         completion(NO, error);
     }];
}

- (NSString *)numberOfVotersText
{
    NSString *countText = [self.largeNumberFormatter stringForInteger:[self totalVotes]];
    switch ([self totalVotes])
    {
        case 1:
            return [NSString stringWithFormat:NSLocalizedString(@"%@ Voter", @""), countText];
        default:
            return [NSString stringWithFormat:NSLocalizedString(@"%@ Voters", @""), countText];
    }
}

@end
