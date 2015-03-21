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

- (BOOL)isHashtagStream;

+ (VStream *)remixStreamForSequence:(VSequence *)sequence; ///<Returns the remix stream for a sequence.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForUser:(VUser *)user; ///<Returns the stream for a user.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForHashTag:(NSString *)hashTag; ///<Returns the stream for a hastag.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForPath:(NSString *)apiPath inContext:(NSManagedObjectContext *)context; ///< Returns a stream with the given api path

@end
