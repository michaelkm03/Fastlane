//
//  VTrendingTagCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHashtag.h"

@interface VTrendingTagCell : UITableViewCell

@property (nonatomic, copy) void (^subscribeToTagAction)(void);
@property (nonatomic, assign) BOOL subscribedToTag;
@property (nonatomic, assign) BOOL shouldAnimateSubscription;

+ (NSInteger)cellHeight;

- (void)setHashtag:(VHashtag *)hashtag;
- (void)updateSubscribeStatus;

@end
