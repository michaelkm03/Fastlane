//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSequence.h"

@class VComposeViewController;

@interface VStreamsCommentsController : UITableViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) VComposeViewController* composeViewController;
@end
