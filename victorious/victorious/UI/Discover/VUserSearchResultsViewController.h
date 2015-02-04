//
//  VUserSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSearchResultsTableViewController.h"

@class VDependencyManager;

@interface VUserSearchResultsViewController : VSearchResultsTableViewController

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

@end
