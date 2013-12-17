//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSequence.h"

@interface VStreamsSubViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) VSequence* sequence;

@end
