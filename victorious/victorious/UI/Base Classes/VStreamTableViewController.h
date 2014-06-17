//
//  VStreamViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreatePollViewController.h"
#import "VAnimation.h"
#import "VSequenceFilter.h"

@class VStreamTableDataSource;

typedef NS_ENUM(NSInteger, VStreamFilter)
{
    VStreamHotFilter = 0,
    VStreamRecentFilter,
    VStreamFollowingFilter
};

@protocol VStreamTableDelegate <NSObject>
@optional
- (void)streamWillDisappear;
@end

@interface VStreamTableViewController : UITableViewController <VAnimation, VCreateSequenceDelegate>

- (NSArray*)sequenceCategories;
- (VSequenceFilter*)currentFilter;
- (NSString*)streamName;

@property (nonatomic) VStreamFilter filterType;

@property (strong, nonatomic, readonly) VStreamTableDataSource* tableDataSource;
@property (strong, nonatomic) VSequence* selectedSequence;
@property (strong, nonatomic) NSArray* repositionedCells;;
@property (weak, nonatomic) id<VStreamTableDelegate, UITableViewDelegate> delegate;

- (void)refreshWithCompletion:(void(^)(void))completionBlock;

@end
