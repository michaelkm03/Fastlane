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
@interface DiscoverSearchViewController : UIViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) SearchResultsViewController *userSearchViewController;
@property (nonatomic, strong) SearchResultsViewController *hashtagsSearchViewController;
@property (nonatomic, strong) SearchResultsViewController *currentSearchVC;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchResultsTableBottomCosntraint;
@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, weak) IBOutlet UIView *opaqueBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *searchBarTopHorizontalRule;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
