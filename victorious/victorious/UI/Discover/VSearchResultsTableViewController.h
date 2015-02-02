//
//  VSearchResultsTableViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSearchResultsTableViewControllerDelegate;

@interface VSearchResultsTableViewController : UITableViewController

/**
 Delegate to return status on search results
 */
@property (nonatomic, weak) id<VSearchResultsTableViewControllerDelegate>delegate;

@end

/**
 Delegate for returning information on users and tag searches
 */
@protocol VSearchResultsTableViewControllerDelegate <NSObject>


@optional
/**
 Reports on if results were returned from backend search request
 
 @param searchResultsTableViewController An instance of the VSearchResultsTableViewController.
 */
- (void)noResultsReturnedForSearch:(VSearchResultsTableViewController *)searchResultsTableViewController;

@end
