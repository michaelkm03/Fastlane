//
//  VUsersAndTagsSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class VDependencyManager, VUsersAndTagsSearchViewController,
VUserSearchResultsViewController, VTagsSearchResultsViewController;

extern NSString * const kVUserSearchResultsChangedNotification;
extern NSString * const kVHashtagsSearchResultsChangedNotification;

@interface VUsersAndTagsSearchViewController : UIViewController

@property (nonatomic, strong) VUserSearchResultsViewController *userSearchResultsVC;
@property (nonatomic, strong) VTagsSearchResultsViewController *tagsSearchResultsVC;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Factory method to load VUsersAndTagsSearchViewController view controller
 
 @return Instance of VUsersAndTagsSearchViewController view controller
 */
+ (instancetype)usersAndTagsSearchViewController;

/**
 Initializer with VDependencyManager
 
 @param dependencyManager Instance of VDependencyManager
 
 @return Instance of VUsersAndTagsSearchViewController view controller
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)userSearch:(NSString *)userName;
- (void)hashtagSearch:(NSString *)tagName;
- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (void)updateTableView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchResultsTableBottomCosntraint;
@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, weak) IBOutlet UIView *opaqueBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *searchBarTopHorizontalRule;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@end
