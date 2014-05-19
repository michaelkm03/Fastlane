//
//  VStreamViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

#import "VCreatePollViewController.h"
#import "VAnimation.h"
#import "VSequenceFilter.h"

typedef NS_ENUM(NSInteger, VStreamFilter)
{
    VStreamHotFilter = 0,
    VStreamRecentFilter,
    VStreamFollowingFilter
};

@protocol VStreamTableDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)streamWillDisappear;
@end

@interface VStreamTableViewController : VFetchedResultsTableViewController <VAnimation, VCreateSequenceDelegate>

- (NSArray*)sequenceCategories;
- (VSequenceFilter*)currentFilter;
- (NSString*)streamName;

@property (nonatomic) VStreamFilter filterType;

@property (strong, nonatomic) NSArray* repositionedCells;;
@property (weak, nonatomic) id<VStreamTableDelegate> delegate;

@end
