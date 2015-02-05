//
//  VTagsSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VTagsSearchResultsViewController;

/**
 Protocol to report when searching has been completed
 */
@protocol VTagsSearchResultsViewControllerDelegate <NSObject>

/**
 Implemented to report when searching should end
 
 @param userSearchResultsViewController Instance of the VUserSearchResultsViewController
 */
- (void)tagsSearchComplete:(VTagsSearchResultsViewController *)tagsSearchResultsViewController;

@end

@interface VTagsSearchResultsViewController : UITableViewController

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
 Delegate object to report on hashtag searching
 */
@property (nonatomic, weak) id<VTagsSearchResultsViewControllerDelegate>delegate;

@end
