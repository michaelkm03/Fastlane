//
//  VPagedFetchTableCell.h
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"

@interface VPagedFetchTableCell : VTableViewCell

@property (nonatomic, strong) NSArray* pageViews;
@property (readonly, nonatomic) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

- (void)performFetch;

@end
