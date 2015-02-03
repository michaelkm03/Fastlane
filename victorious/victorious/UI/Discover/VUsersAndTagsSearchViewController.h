//
//  VUsersAndTagsSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@interface VUsersAndTagsSearchViewController : UIViewController

/**
 Factory method to load VUsersAndTagsSearchViewController view controller
 
 @return Instance of VUsersAndTagsSearchViewController view controller
 */
+ (instancetype)usersAndTagsSearchViewController;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchBarViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchResultsTableBottomCosntraint;
@property (nonatomic, weak) IBOutlet UIView *searchResultsContainerView;
@property (nonatomic, weak) IBOutlet UIView *opaqueBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *searchBarTopHorizontalRule;

@end
