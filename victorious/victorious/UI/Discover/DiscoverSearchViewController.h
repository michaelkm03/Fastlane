//
//  DiscoverSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@protocol SearchResultsViewControllerDelegate;

@class VDependencyManager, DiscoverSearchViewController, VUserSearchResultsViewController, VTagsSearchResultsViewController;

@class SearchResultsViewController;

/**
 A view controller that offers a promiment search bar and a segmented control that hides and shows
 various child view controllers that can display search results for various types of content.
 */
@interface DiscoverSearchViewController : UIViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) SearchResultsViewController *userSearchViewController;
@property (nonatomic, strong) SearchResultsViewController *hashtagsSearchViewController;

@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Sets the search bar hidden.  This allows calling code to provide its own search bar UI
 and hide the built-in, default search bar this view controller provides.
 */
@property (nonatomic, assign) BOOL searchBarHidden;

/**
 An optional delegate to respond to search actions.  Methods on this delegate will be
 called for EACH search results tab contained in this view controller/
 */
@property (nonatomic, weak) id<SearchResultsViewControllerDelegate> searchResultsDelegate;

@end
