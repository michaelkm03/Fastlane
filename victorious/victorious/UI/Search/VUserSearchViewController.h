//
//  VUserSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager, VUser, VUserSearchViewController;

@protocol VSearchResultsViewControllerDelegate <NSObject>

@required

- (void)didSelectUser:(VUser *)user inUserSearchViewController:(VUserSearchViewController *)userSearchViewController;

@end

@interface VUserSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/**
 Possible viewcontrollers who present this VUserSearchViewController.
 */
typedef NS_ENUM(NSInteger, VUserSearchPresenter)
{
    VUserSearchPresenterNone, // Default value when it's not set. It's unexpected to see this
    VUserSearchPresenterMessages // Set when the presenter is VInboxViewController
};

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 A context for this search.
 
 Acceptable Values:
 VObjectManagerSearchContextMessage: A search context for finding messagable users
 VObjectManagerSearchContextUserTag: A search context for finding taggable users
 VObjectManagerSearchContextDiscover: A search context for the discover user search
 
 Defaults to: VObjectManagerSearchContextDiscover
 */
@property (nonatomic, strong) NSString *searchContext;
@property (nonatomic, weak) id <VSearchResultsViewControllerDelegate> messageSearchDelegate;
@property (nonatomic, assign) VUserSearchPresenter userSearchPresenter;

@end
