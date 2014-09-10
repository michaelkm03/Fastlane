//
//  VStream+Fetcher.h
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream.h"

@class VUser;

@interface VStream (Fetcher)

+ (VStream*)remixStreamForSequence:(VSequence*)sequence;
+ (VStream*)streamForUser:(VUser*)user;
+ (VStream*)streamForCategories:(NSArray*)categories;
+ (VStream*)hotSteamForSteamName:(NSString*)streamName;
+ (VStream*)streamForHashTag:(NSString*)hashTag;
+ (VStream*)followerStreamForStreamName:(NSString*)streamName user:(VUser*)user;

@end
