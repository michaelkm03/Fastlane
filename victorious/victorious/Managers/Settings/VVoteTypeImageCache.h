//
//  VVoteTypeImageCache.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVoteType;

@interface VVoteTypeImageCache : NSObject

- (void)cacheImagesForVoteType:(VVoteType *)voteType;

@end
