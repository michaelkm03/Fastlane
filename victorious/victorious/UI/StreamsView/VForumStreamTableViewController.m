//
//  VForumStreamTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForumStreamTableViewController.h"
#import "VStreamsTableViewController+Protected.h"
#import "VCreateTopicViewController.h"

@implementation VForumStreamTableViewController

+ (instancetype)sharedStreamsTableViewController
{
    static  VForumStreamTableViewController*   streamsTableViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        streamsTableViewController = (VForumStreamTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"forumstream"];
    });
    
    return streamsTableViewController;
}

- (IBAction)addButtonAction:(id)sender
{
    VCreateTopicViewController *createViewController = [[VCreateTopicViewController alloc] initWithDelegate:self];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
}

//#pragma mark - Segue Lifecycle
//- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender;
//
#pragma mark - Predicate Lifecycle
- (NSArray*)imageCategories
{
    return nil;
}

- (NSArray*)videoCategories
{
    return nil;
}

- (NSArray*)pollCategories
{
    return nil;
}



//#pragma mark - Cell Lifecycle
//- (void)registerCells;
//- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath;

@end
