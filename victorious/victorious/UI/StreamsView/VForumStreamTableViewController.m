//
//  VForumStreamTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForumStreamTableViewController.h"
#import "VStreamsTableViewController+Protected.h"

@implementation VForumStreamTableViewController

//#pragma mark - Segue Lifecycle
//- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender;
//
#pragma mark - Predicate Lifecycle

//- (NSPredicate*)scopeTypePredicate
//{
//    
//}
//
//- (NSPredicate*)searchTextPredicate
//{
//    
//}

//- (NSPredicate*)forumPredicate;

- (NSPredicate*)imagePredicate
{
    return nil;
}
- (NSPredicate*)pollPredicate
{
    return nil;
}
- (NSPredicate*)videoPredicate
{
    return nil;
}

//#pragma mark - Cell Lifecycle
//- (void)registerCells;
//- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath;

@end
