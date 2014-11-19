//
//  VStream+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream.h"

@class VUser, VSequence;

extern NSString * const VStreamFilterTypeRecent;
extern NSString * const VStreamFilterTypePopular;

extern NSString * const VStreamFollowerStreamPath;

@interface VStream (Fetcher)

- (BOOL)onlyContainsSequences;///<Returns True if the stream only contains sequences.  Else false.
- (BOOL)isStreamOfStreams;

+ (VStream *)remixStreamForSequence:(VSequence *)sequence; ///<Returns the remix stream for a sequence.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForUser:(VUser *)user; ///<Returns the stream for a user.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForCategories:(NSArray *)categories; ///<Returns the stream for given catgories.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)hotSteamForSteamName:(NSString *)streamName; ///<Returns the hot stream for streamName.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForHashTag:(NSString *)hashTag; ///<Returns the stream for a hastag.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)followerStreamForStreamName:(NSString *)streamName user:(VUser *)user; ///<Returns the following stream for streamName.  Note: stream object will be the mainQueueManagedObjectContext.  Note: If no user is given, defaults to logged in user.
+ (VStream *)streamForChannelsDirectory;///<Returns the Channels stream.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForMarqueeInContext:(NSManagedObjectContext *)context;///<Returns the Marquee stream.
+ (VStream *)streamForPath:(NSString *)apiPath inContext:(NSManagedObjectContext *)context; ///< Returns a stream with the given api path

@end
