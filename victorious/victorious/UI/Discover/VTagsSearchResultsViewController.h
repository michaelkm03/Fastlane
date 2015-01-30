//
//  VTagsSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSearchResultsTableViewController.h"

@interface VTagsSearchResultsViewController : VSearchResultsTableViewController

/**
 Array to hold search results returned from backend
 */
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
