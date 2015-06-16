//
//  VLikeHelper.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLikeHelper, VSequence;

@protocol VLikeResponder <NSObject>

@property (nonatomic, readonly) VLikeHelper *likeHelper;

@end

@interface VLikeHelper : NSObject

- (void)likeSequence:(VSequence *)sequence completion:(void(^)(VSequence *sequence))completion;

- (void)unlikeSequence:(VSequence *)sequence completion:(void(^)(VSequence *sequence))completion;

@end
