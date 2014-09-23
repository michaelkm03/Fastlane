//
//  VRealtimeCommentsViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRealtimeCommentsViewModel.h"

// Formatters
#import "NSDate+timeSince.h"
#import "VRTCUserPostedAtFormatter.h"

// Models
#import "VComment.h"
#import "VUser.h"

@interface VRealtimeCommentsViewModel ()

@property (nonatomic, strong) VComment *currentComment;

@end

@implementation VRealtimeCommentsViewModel

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentTime = kCMTimeZero;
    }
    return self;
}

- (void)setRealTimeComments:(NSArray *)realTimeComments
{
    NSMutableArray *realRealTimeComments = [[NSMutableArray alloc] init];
    
    [realTimeComments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if (![obj isKindOfClass:[VComment class]])
        {
            return;
        }
        VComment *comment = (VComment *)obj;
        if (!comment.realtime)
        {
            return;
        }
        
        [realRealTimeComments addObject:comment];
    }];
    
    _realTimeComments = realRealTimeComments;
    
    [self.delegate realtimeCommentsViewModelDidLoadNewComments:self];
}

- (NSInteger)numberOfRealTimeComments
{
    return self.realTimeComments.count;
}

- (NSString *)usernameForCurrentRealtimeComment
{
    return self.currentComment.user.name;
}

- (NSURL *)avatarURLForCurrentRealtimeComent
{
    return [NSURL URLWithString:self.currentComment.user.pictureUrl];
}

- (NSString *)timeAgoTextForCurrentRealtimeComment
{
    return [self.currentComment.postedAt timeSince];
}

- (NSString *)atRealtimeTextForCurrentRealTimeComment
{
    return [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:@""
                                                                   andPostedTime:self.currentComment.realtime].string;
}

- (NSString *)realTimeCommentBodyForCurrentRealTimeComent
{
    return self.currentComment.text;
}

- (void)setCurrentTime:(CMTime)currentTime
{
    _currentTime = currentTime;
    
    Float64 seconds = CMTimeGetSeconds(currentTime);
    
    __block VComment *newCurrentComment = [self.realTimeComments firstObject];
    
    [self.realTimeComments enumerateObjectsUsingBlock:^(VComment *comment, NSUInteger idx, BOOL *stop)
    {
        if (comment.realtime.floatValue > seconds)
        {
            newCurrentComment = comment;
            *stop = YES;
        }
    }];
    
    self.currentComment = newCurrentComment;
}

- (void)setCurrentComment:(VComment *)currentComment
{
    if (_currentComment == currentComment)
    {
        return;
    }
    _currentComment = currentComment;
    
    [self.delegate currentCommentDidChangeOnRealtimeCommentsViewModel:self];
}

#pragma mark - Public Methods

- (NSURL *)avatarURLForRealTimeCommentAtIndex:(NSInteger)index
{
    VComment *commentAtIndex = [self.realTimeComments objectAtIndex:index];
    return [NSURL URLWithString:commentAtIndex.user.pictureUrl];
}

- (CGFloat)percentThroughMediaForRealTimeCommentAtIndex:(NSInteger)index
{
    if (!CMTIME_IS_VALID(self.totalTime))
    {
        return 0.0f;
    }
    VComment *commentAtIndex = [self.realTimeComments objectAtIndex:index];
    CGFloat percentThrought = commentAtIndex.realtime.floatValue / CMTimeGetSeconds(self.totalTime);
    return percentThrought;
}

- (CGFloat)percentThroughMediaForCurrentRealTimeComment
{
    return !isnan(self.currentComment.realtime.doubleValue / CMTimeGetSeconds(self.totalTime)) ? (self.currentComment.realtime.doubleValue / CMTimeGetSeconds(self.totalTime)) : 0.0f;
}

@end
