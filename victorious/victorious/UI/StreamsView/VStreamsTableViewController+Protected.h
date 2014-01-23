//
//  VStreamsTableViewController+Protected.h
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamsTableViewController.h"

#import "VStreamViewCell.h"
#import "VStreamVideoCell.h"
#import "VStreamPollCell.h"

@interface VStreamsTableViewController (Protected)

#pragma mark - Segue Lifecycle
- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (NSArray*)imageCategories;
- (NSArray*)videoCategories;
- (NSArray*)pollCategories;
- (NSArray*)forumCategories;

@end
