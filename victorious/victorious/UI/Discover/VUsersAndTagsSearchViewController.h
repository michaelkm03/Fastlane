//
//  VUsersAndTagsSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class VDependencyManager;

@interface VUsersAndTagsSearchViewController : UIViewController

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
+ (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchResultsTableBottomCosntraint;
@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, weak) IBOutlet UIView *opaqueBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *searchBarTopHorizontalRule;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@end
