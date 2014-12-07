//
//  VInboxViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

@class VUnreadMessageCountCoordinator;

@interface VInboxViewController : VFetchedResultsTableViewController

@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;

+ (instancetype)inboxViewController;

- (void)toggleFilterControl:(NSInteger)idx;
- (IBAction)userSearchAction:(id)sender;

@end
