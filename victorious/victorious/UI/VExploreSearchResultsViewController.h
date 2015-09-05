//
//  VExploreSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUsersAndTagsSearchViewController.h"

@class VDependencyManager, VExploreSearchResultsViewController;
@protocol ExploreSearchResultNavigationDelegate;

@interface VExploreSearchResultsViewController : VUsersAndTagsSearchViewController <UISearchBarDelegate>

@property (nonatomic, weak) id<ExploreSearchResultNavigationDelegate> navigationDelegate;

@end
