//
//  VFileCache+VoteType.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const VFileCacheCachedFilepathFormat;
extern NSString * const VFileCacheCachedSpriteNameFormat;
extern NSString * const VFileCacheCachedIconName;

@class VVoteType;

@interface VFileCache (VoteType)

/**
 Download and save the files to the cache directory asynchronously
 */
- (BOOL)cacheImagesForVoteType:(VVoteType *)voteType;

/**
 Retrieve the icon image synchronously.
 */
- (UIImage *)getIconImageForVoteType:(VVoteType *)voteType;

/**
 Retrieve an array of sprite images synchronously.
 */
- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType;

/**
 Retrieve an array of sprite images asynchronously.
 */
- (BOOL)getSpriteImagesForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback;

/**
 Retrieve the icon image asynchronously.
 */
- (BOOL)getIconImageForVoteType:(VVoteType *)voteType completionCallback:(void(^)(UIImage *))callback;

@end
