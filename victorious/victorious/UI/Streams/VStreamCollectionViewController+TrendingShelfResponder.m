//
//  VStreamCollectionViewController+TrendingShelfResponder.m
//  victorious
//
//  Created by Sharif Ahmed on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController+TrendingShelfResponder.h"

@implementation VStreamCollectionViewController (TrendingShelfResponder)

- (void)navigateTo:(VStreamItem *__nonnull)streamItem fromShelf:(VShelf *__nonnull)fromShelf
{
    [self navigateToStream:fromShelf.stream atStreamItem:streamItem];
}

- (void)trendingUserShelfSelected:(VUser *__nonnull)user fromShelf:(UserShelf *__nonnull)fromShelf
{
    [self.sequenceActionController showProfile:user fromViewController:self];
}

- (void)trendingHashtagShelfSelected:(NSString *__nonnull)hashtag fromShelf:(HashtagShelf *__nonnull)fromShelf
{
    [self navigateToStream:fromShelf.stream atStreamItem:nil];
}

@end
