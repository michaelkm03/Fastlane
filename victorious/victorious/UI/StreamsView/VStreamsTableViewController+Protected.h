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

#import "VSequence+VFetcher.h"

@interface VStreamsTableViewController (Protected)

#pragma mark - Segue Lifecycle
- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender;

#pragma mark - Predicate Lifecycle
- (NSPredicate*)searchTextPredicate;
- (NSPredicate*)scopeTypePredicate;

- (NSPredicate*)defaultTypePredicate;
- (NSPredicate*)forumPredicate;
- (NSPredicate*)imagePredicate;
- (NSPredicate*)pollPredicate;
- (NSPredicate*)videoPredicate;

#pragma mark - Cell Lifecycle
- (void)registerCells;
- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath;

@end
