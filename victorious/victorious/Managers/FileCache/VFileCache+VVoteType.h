//
//  VFileCache+VVoteType.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const VVoteTypeFilepathFormat;
extern NSString * const VVoteTypeSpriteNameFormat;
extern NSString * const VVoteTypeIconName;
extern NSString * const VVoteTypeIconLargeName;

@class VVoteType;

@interface VFileCache (VVoteType)

/**
 A block that can be set by calling code to provide any modifications to the data
 before it is written, e.g. wrapping it in UIImagePNGRepresentation()
 */
@property (nonatomic, copy) NSData *(^encoderBlock)(NSData *);

/**
 A block that can be set by calling code to provide any modifications to the data
 after it is read.
 */
@property (nonatomic, copy) id (^decoderBlock)(NSData *);

/**
 Download and save the files to the cache directory asynchronously
 */
- (void)cacheImagesForVoteTypes:(NSArray *)voteTypes;

/**
 Retrieve an image synchronously.
 */
- (UIImage *)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType;

/**
 Retrieve an array of sprite images synchronously.
 */
- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType;

/**
 Retrieve an array of sprite images asynchronously.
 */
- (BOOL)getSpriteImagesForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback;

/**
 Retrieve an image asynchronously.
 */
- (BOOL)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType completionCallback:(void(^)(UIImage *))callback;

/**
 Check if an image is saved to disk.
 */
- (BOOL)isImageCached:(NSString *)imageName forVoteType:(VVoteType *)voteType;

/**
 Check if all required sprite images in an animation sequence are saved to disk.
 */
- (BOOL)areSpriteImagesCachedForVoteType:(VVoteType *)voteType;

- (NSString *)savePathForImage:(NSString *)imageName forVote:(VVoteType *)voteType;

@end
