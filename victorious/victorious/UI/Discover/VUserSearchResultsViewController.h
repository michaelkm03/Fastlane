//
//  VUserSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VUserSearchResultsViewController;

/**
 Protocol to report when searching has been completed
 */
@protocol VUserSearchResultsViewControllerDelegate <NSObject>

/**
 Implemented to report when searching should end
 
 @param userSearchResultsViewController Instance of the VUserSearchResultsViewController
 */
- (void)userSearchComplete:(VUserSearchResultsViewController *)userSearchResultsViewController;

@end

@interface VUserSearchResultsViewController : UITableViewController

/**
 Factory method to instantiate the View Controller with the dependency manager
 
 @param dependencyManager VDependencyManager instance
 
 @return An instance of VTagsSearchResultsViewController
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Array to hold search results returned from backend
 */
@property (nonatomic, strong) NSMutableArray *searchResults;

/**
 Delegate object to report on user search
 */
@property (nonatomic, weak) id<VUserSearchResultsViewControllerDelegate>delegate;

@end
