//
//  VVoteType+Fetcher.h
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"

@interface VVoteType (Fetcher)

+ (VVoteType*)likeVote;
+ (VVoteType*)dislikeVote;

- (NSArray*)imageURLs;

@end
