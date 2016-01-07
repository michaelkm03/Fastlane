//
//  VExploreSearchResultsViewController.m
//  victorious
//
//  Created by Tian Lan on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VExploreSearchResultsViewController.h"
#import "VUserSearchResultsViewController.h"
#import "VTagsSearchResultsViewController.h"
#import "victorious-Swift.h"

@interface VExploreSearchResultsViewController ()

@property (nonatomic, strong) NSString *lastSearchText;

@end

@implementation VExploreSearchResultsViewController

#pragma mark - Factory Methods

+ (instancetype)usersAndTagsSearchViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"search"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VExploreSearchResultsViewController *usersAndTagsVC = [self usersAndTagsSearchViewController];
    usersAndTagsVC.dependencyManager = dependencyManager;
    return usersAndTagsVC;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME
    //self.userSearchResultsVC.navigationDelegate = self.navigationDelegate;
    self.tagsSearchResultsVC.navigationDelegate = self.navigationDelegate;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self textFieldShouldClear:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchWithSearchTerm:searchBar.text];
}

@end
