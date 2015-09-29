//
//  VObjectManager+ContentModeration.h
//  victorious
//
//  Created by Sharif Ahmed on 9/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager.h"

typedef NS_ENUM(NSInteger, VFlaggedContentType)
{
    VFlaggedContentTypeStreamItem,
    VFlaggedContentTypeComment
};

@interface VObjectManager (ContentModeration)

- (void)refreshFlaggedContents;

- (NSArray *)commentsAfterStrippingFlaggedItems:(NSArray *)comments;
- (NSArray *)streamItemsAfterStrippingFlaggedItems:(NSArray *)streamItems;

- (NSArray *)flaggedContentIdsWithType:(VFlaggedContentType)type;

- (void)addRemoteId:(NSString *)remoteId toFlaggedItemsWithType:(VFlaggedContentType)type;

@end
