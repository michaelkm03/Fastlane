//
//  DiscoverSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class VDependencyManager, DiscoverSearchViewController, VUserSearchResultsViewController, VTagsSearchResultsViewController;

@class SearchResultsViewController;

/**
 A view controller that offers a promiment search bar and a segmented control that hides and shows
 various child view controllers that can display search results for various types of content.
 */
@interface DiscoverSearchViewController : UIViewController <UISearchBarDelegate>

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) SearchResultsViewController *userSearchViewController;
@property (nonatomic, strong) SearchResultsViewController *hashtagsSearchViewController;

@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
