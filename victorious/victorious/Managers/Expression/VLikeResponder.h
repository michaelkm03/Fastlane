//
//  VLikeResponder.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

@protocol VLikeResponder <NSObject>

- (void)toggleLikeSequence:(VSequence *)sequence completion:(void(^)(BOOL))completion;

@end
