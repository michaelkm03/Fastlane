//
//  VRealtimeCommentsViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VRealtimeCommentsViewModel;

@protocol VRealtimeCommentsViewModelDelegate <NSObject>

- (void)realtimeCommentsViewModelDidLoadNewComments:(VRealtimeCommentsViewModel *)viewModel;
- (void)currentCommentDidChangeOnRealtimeCommentsViewModel:(VRealtimeCommentsViewModel *)viewModel;
- (void)realtimeCommentsReadyToLoadRTC:(VRealtimeCommentsViewModel *)viewModel;

@end

@import AVFoundation;

/**
 VRealtimeCommentsViewModel manages the state inherent in displaying and presenting real time comments. It is initialized with an array of comments that it uses as a sort of data source. As the currentTime property is updated so too are the various ___ForCurrentRealTimeComment properties. These reflect the info necessary for display in the UI. In order to display a strip of realTimeComment avatars use the numberOfRealTimeComments and iterate calls to -avatarURLForRealTimeCommentAtIndex: from 0 to the value returned from the numberOfRealTimeComments property.
 
 
 */
@interface VRealtimeCommentsViewModel : NSObject

/**
 *  An array of VComment objects that have a realtime timestamp property. Prunes objects that are not of type VComment or have a nil realtime property.
 */
@property (nonatomic, strong) NSArray *realTimeComments;

@property (nonatomic, weak) id <VRealtimeCommentsViewModelDelegate> delegate;

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

/**
 *  The location of the real time comment relative to the media.
 *
 *  @param index The index of the realtime comment.
 *
 *  @return A percent location for the realtime comment.
 */
- (CGFloat)percentThroughMediaForRealTimeCommentAtIndex:(NSInteger)index;

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
 *  The comment body for the current comment.
 */
@property (nonatomic, readonly) NSString *realTimeCommentBodyForCurrentRealTimeComent;


- (CGFloat)percentThroughMediaForCurrentRealTimeComment;

@end
