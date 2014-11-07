//
//  VInboxViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

@interface VInboxViewController : VFetchedResultsTableViewController

+ (instancetype)inboxViewController;

- (void)toggleFilterControl:(NSInteger)idx;
- (IBAction)userSearchAction:(id)sender;

@end
