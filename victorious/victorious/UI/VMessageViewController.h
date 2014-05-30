//
//  VMessageViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VConversation;
@class VKeyboardBarViewController;

#import "VFetchedResultsTableViewController.h"

@interface VMessageViewController : VFetchedResultsTableViewController

@property (nonatomic, readwrite, strong)    VConversation*  conversation;

@end
