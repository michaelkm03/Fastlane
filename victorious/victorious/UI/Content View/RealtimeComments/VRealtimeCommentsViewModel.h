//
//  VRealtimeCommentsViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

/**
 VRealtimeCommentsViewModel manages the state inherent in displaying and presenting real time comments. It is initialized with an array of comments that it uses as a sort of data source. As the currentTime property is updated so too are the various ___ForCurrentRealTimeComment properties. These reflect the info necessary for display in the UI. In order to display a strip of realTimeComment avatars use the numberOfRealTimeComments and iterate calls to -avatarURLForRealTimeCommentAtIndex: from 0 to the value returned from the numberOfRealTimeComments property.
 
 
 */
@interface VRealtimeCommentsViewModel : NSObject

/**
 *  Designated initializer.
 *
 *  @param realtimeComments An array of VComment objects.
 *
 *  @return An initializaed VRealtimeCommentsViewModel.
 */
- (instancetype)initWithRealtimeComments:(NSArray *)realtimeComments;

/**
 *  The total time of the video this realTimeCommentViewModel corresponds with.
 */
@property (nonatomic, assign) CMTime totalTime;

/**
 *  The current time of the video.
 */
@property (nonatomic, assign) CMTime currentTime;

/**
 *  The number of realtime comments for the video.
 */
@property (nonatomic, readonly) NSInteger numberOfRealTimeComments;

/**
 *  The avatarURL for the comment at the specified index. 0 based.
 *
 *  @param index Zero-based index with acceptable values 0 <= index < numberOfRealTimeComments.
 *
 *  @return The avatar URL for the comment at the specified comment index.
 */
- (NSURL *)avatarURLForRealTimeCommentAtIndex:(NSInteger)index;

- (CGFloat)percentThroughMediaForRealTimeCommentAtIndex:(NSInteger)index;

/**
 *  This block is called every time the current comment changes.
 */
@property (nonatomic, copy) void (^onCurrentRealTimeComentChange)(void);

/**
 *  The current comment's username.
 */
@property (nonatomic, readonly) NSString *usernameForCurrentRealtimeComment;

/**
 *  The avatar URL for the current comment.
 */
@property (nonatomic, readonly) NSURL *avatarURLForCurrentRealtimeComent;

/**
 *  The time ago text for the current realtime comment.
 */
@property (nonatomic, readonly) NSString *timeAgoTextForCurrentRealtimeComment;

/**
 *  The at realtime text for the current comment.
 */
@property (nonatomic, readonly) NSString *atRealtimeTextForCurrentRealTimeComment;

/**
 *  The comment body for the current comment.
 */
@property (nonatomic, readonly) NSString *realTimeCommentBodyForCurrentRealTimeComent;


- (CGFloat)percentThroughMediaForCurrentRealTimeComment;

@end
