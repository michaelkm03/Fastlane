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
#import "VConstants.h"

#import "VObjectManager.h"
#import "VLoginViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(displaySearchBar:)];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(addButtonAction:)];
    
    self.navigationItem.rightBarButtonItems= @[addButtonItem, searchButtonItem];
    self.searchDisplayController.searchBar.scopeButtonTitles = nil;
}

- (IBAction)addButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    VCreateTopicViewController *createViewController = [[VCreateTopicViewController alloc] initWithDelegate:self];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController]
                       animated:YES
                     completion:nil];
}

#pragma mark - Segue Lifecycle
//- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender;

#pragma mark - Predicate Lifecycle

- (NSArray*)categoriesForCurrentScope
{
    return [self forumCategories];
}

- (NSArray*)forumCategories
{
    return @[kVOwnerForumCategory, kVUGCForumCategory];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return  nil;
}

//#pragma mark - Cell Lifecycle
//- (void)registerCells;
//- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath;

@end
