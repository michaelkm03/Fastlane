//
//  VFeaturedStreamsViewController.h
//  victoriOS
//
//  Created by David Keegan on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFeaturedStreamsViewController : UIViewController

@property (readonly, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) UITableViewController* superController;

- (void)performFetch;

@end
