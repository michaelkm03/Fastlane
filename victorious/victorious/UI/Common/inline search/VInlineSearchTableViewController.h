//
//  VInlineSearchTableViewController.h
//  victorious
//
//  Created by Lawrence Leach on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSInteger kSearchTableDesiredMinimumHeight;

@class VInlineSearchTableViewController, VUser;

@protocol VInlineSearchTableViewControllerDelegate <NSObject>

@required

/**
 Method that is called when a user is selected from the list of users returned in a search
 
 @param user          VUser objects selected from the table view
 @param vInlineSearch Instance of the tableview controller being displayed
 */
- (void)user:(VUser *)user wasSelectedFromTableView:(VInlineSearchTableViewController *)vInlineSearch;
- (void)dismissButtonWasPressedInTableView:(VInlineSearchTableViewController *)vInlineSearch;

@end

@interface VInlineSearchTableViewController : UITableViewController

/**
 Delegate object for the controller protocol
 */
@property (nonatomic, weak) id <VInlineSearchTableViewControllerDelegate> delegate;

/**
 Called to perform a user search
 
 @param searchText NSString text to search for
 */
- (void)searchFollowingList:(NSString *)searchText;

@end
