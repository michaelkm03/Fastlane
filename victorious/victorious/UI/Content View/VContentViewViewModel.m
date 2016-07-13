//
//  VContentViewViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewViewModel.h"
#import "VComment.h"
#import "VAsset.h"
#import "VAnswer.h"
#import "VPollResult.h"
#import "VVoteType.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VComment+Fetcher.h"
#import "NSString+VParseHelp.h"
#import "VLargeNumberFormatter.h"
#import "NSURL+MediaType.h"
#import "VStream.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"
#import <KVOController/FBKVOController.h>

@interface VContentViewViewModel ()

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong, readwrite) VAsset *currentAsset;
@property (nonatomic, strong, readwrite) VExperienceEnhancerController *experienceEnhancerController;
@property (nonatomic, strong, readwrite) ContentViewContext *context;
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
        _experienceEnhancerController = [[VExperienceEnhancerController alloc] initWithDependencyManager:childDependencyManager
                                                                                         purchaseManager:[VPurchaseManager sharedInstance]];
        
        _currentNode = [_sequence firstNode];
        
        if ([_sequence isPoll])
        {
            _type = VContentViewTypePoll;
        }
        else if ([_sequence isVideo] && ![_sequence isGIFVideo])
        {
            _type = VContentViewTypeVideo;
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
        _commentsDataSource = [[CommentsDataSource alloc] initWithSequence:context.sequence
                                                         dependencyManager:self.dependencyManager];
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
    return [self initWithContext:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return [[UIColor alloc] initWithRgbHexString:self.currentAsset.backgroundColor];
}

- (NSURL *)textBackgroundImageURL
{
    VAsset *imageAsset = [self.sequence.firstNode imageAsset];
    return [NSURL URLWithString:imageAsset.data];
}

#pragma mark - Public Methods

- (NSString *)commentTimeAgoTextForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.sequence.comments objectAtIndex:commentIndex];
    return [commentForIndex.postedAt stringDescribingTimeIntervalSinceNow];
}

- (VUser *)userForCommentIndex:(NSInteger)commentIndex
{
    VComment *commentForIndex = [self.sequence.comments objectAtIndex:commentIndex];
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

- (NSString *)memeCountText
{
    return [NSString stringWithFormat:@"%@", self.sequence.memeCount];
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
    VComment *commentForIndex = [self.sequence.comments objectAtIndex:commentIndex];
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
    for (VPollResult *result in [VCurrentUser user].pollResults)
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
    
    for (VPollResult *result in self.pollResults)
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
    
    for (VPollResult *result in self.pollResults)
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
    for (VPollResult *pollResult in self.pollResults)
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
        for (VPollResult *result in [VCurrentUser user].pollResults)
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

- (NSURL *)avatarForAuthorWithSize:(CGSize)size
{
    return [self.sequence.user pictureURLOfMinimumSize:size];
}

@end
