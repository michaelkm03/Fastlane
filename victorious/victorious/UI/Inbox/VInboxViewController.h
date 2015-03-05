//
//  VInboxViewController.h
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

@class VUnreadMessageCountCoordinator, VUser;

@interface VInboxViewController : VFetchedResultsTableViewController

@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;

+ (instancetype)inboxViewController;

- (void)displayConversationForUser:(VUser *)user; ///< Pushes the conversation view for the given user onto the navigation controller
- (IBAction)userSearchAction:(id)sender;

@end
