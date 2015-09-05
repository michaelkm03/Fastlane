//
//  VExploreSearchResultsViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class VDependencyManager, VExploreSearchResultsViewController;
@protocol ExploreSearchResultNavigationDelegate;

@interface VExploreSearchResultsViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, weak) id<ExploreSearchResultNavigationDelegate> navigationDelegate;

/**
 Factory method to load VExploreSearchResultsViewController view controller
 
 @return Instance of VExploreSearchResultsViewController view controller
 */
+ (instancetype)usersAndTagsSearchViewController;

/**
 Initializer with VDependencyManager
 
 @param dependencyManager Instance of VDependencyManager
 
 @return Instance of VExploreSearchResultsViewController view controller
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;

@end
