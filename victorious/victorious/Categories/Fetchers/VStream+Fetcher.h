//
//  VStream+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream.h"

@import VictoriousIOSSDK;

@class VUser, VSequence;

extern NSString * const VStreamFilterTypeRecent;
extern NSString * const VStreamFilterTypePopular;

@interface VStream (Fetcher)

- (BOOL)isHashtagStream;
- (BOOL)hasMarquee;
- (BOOL)hasShelfID;

+ (VStream *)streamForUser:(VUser *)user; ///<Returns the stream for a user.  Note: stream object will be the mainQueueManagedObjectContext.
+ (VStream *)streamForPath:(NSString *)apiPath inContext:(NSManagedObjectContext *)context; ///< Returns a stream with the given api path
+ (VStream *)streamForPath:(NSString *)apiPath
                 inContext:(NSManagedObjectContext *)context
            withEntityName:(NSString *)entityName;

@end
