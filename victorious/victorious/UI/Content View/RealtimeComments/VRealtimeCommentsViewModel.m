//
//  VRealtimeCommentsViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRealtimeCommentsViewModel.h"

// Models
#import "VComment.h"
#import "VUser.h"

@interface VRealtimeCommentsViewModel ()

@property (nonatomic, strong, readwrite) NSArray *realTimeComments;

@property (nonatomic, strong) VComment *currentComment;

@end

@implementation VRealtimeCommentsViewModel

#pragma mark - Initializer

- (instancetype)initWithRealtimeComments:(NSArray *)realtimeComments
                               totalTime:(CGFloat)totalTime
{
    self = [super init];
    if (self)
    {
        _totalTime = totalTime;
        _realTimeComments = realtimeComments;
        _currentTime = 0.0f;
    }
    return self;
}

#pragma mark - Property Accessors

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
    //TODO: Implement
    return @"";
}

- (NSString *)atRealtimeTextForCurrentRealTimeComment
{
    //TODO: Implement
    return @"";
}

- (NSString *)realTimeCommentBodyForCurrentRealTimeComent
{
    return self.currentComment.text;
}

- (void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    
    [self.realTimeComments enumerateObjectsUsingBlock:^(VComment *comment, NSUInteger idx, BOOL *stop)
    {
        if (comment.realtime.floatValue > self.currentComment.realtime.floatValue)
        {
            self.currentComment = comment;
            *stop = YES;
        }
    }];
}

#pragma mark - Public Methods

- (NSURL *)avatarURLForRealTimeCommentAtIndex:(NSInteger)index
{
    VComment *commentAtIndex = [self.realTimeComments objectAtIndex:index];
    return [NSURL URLWithString:commentAtIndex.user.pictureUrl];
}

@end
