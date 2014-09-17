//
//  VRealtimeCommentsViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRealtimeCommentsViewModel : NSObject

- (instancetype)initWithRealtimeComments:(NSArray *)realtimeComments
                               totalTime:(CGFloat)totalTime;

@property (nonatomic, readonly) CGFloat totalTime;
@property (nonatomic, assign) CGFloat currentTime;

@property (nonatomic, readonly) NSInteger numberOfRealTimeComments;
- (NSURL *)avatarURLForRealTimeCommentAtIndex:(NSInteger)index;

@property (nonatomic, readonly) NSString *usernameForCurrentRealtimeComment;
@property (nonatomic, readonly) NSURL *avatarURLForCurrentRealtimeComent;
@property (nonatomic, readonly) NSString *timeAgoTextForCurrentRealtimeComment;
@property (nonatomic, readonly) NSString *atRealtimeTextForCurrentRealTimeComment;
@property (nonatomic, readonly) NSString *realTimeCommentBodyForCurrentRealTimeComent;

@end
