//
//  VTrendingTagCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHashtag, VFollowHashtagControl;

@interface VTrendingTagCell : UITableViewCell

@property (nonatomic, copy) void (^subscribeToTagAction)(void);
@property (nonatomic, readonly) BOOL subscribedToTag;
@property (nonatomic, assign) BOOL shouldAnimateSubscription;
@property (nonatomic, weak) IBOutlet VFollowHashtagControl *followHashtagControl;

+ (NSInteger)cellHeight;

- (void)setHashtag:(VHashtag *)hashtag;
- (void)updateSubscribeStatus;

@end
