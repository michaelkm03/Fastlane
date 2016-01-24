//
//  VExploreSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "DiscoverSearchViewController.h"

@class VDependencyManager, VExploreSearchResultsViewController;

@protocol ExploreSearchResultNavigationDelegate;

/// The view controller to manage the presentation of explore search results
/// This view is shown when user starts to edit the search field
/// This view is dismissed when user clears the search field
@interface VExploreSearchResultsViewController : DiscoverSearchViewController

@property (nonatomic, weak) id<ExploreSearchResultNavigationDelegate> navigationDelegate;

@end
