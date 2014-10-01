//
//  VFindFriendsTableViewController.h
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VFindFriendsTableViewState)
{
    VFindFriendsTableViewStatePreConnect, ///< User has yet to connect to the social network, view is displaying connect button
    VFindFriendsTableViewStateConnecting, ///< User has authorized connection, we are asynchronously waiting for social network to connect
    VFindFriendsTableViewStateConnected, ///< User as connected to the social network, but we haven't loaded friends yet
    VFindFriendsTableViewStateLoading,   ///< Asynchronously waiting for social network to deliver friends
    VFindFriendsTableViewStateLoaded,    ///< Friends have been loaded, view is displaying friends
    VFindFriendsTableViewStateError      ///< User has authorized connection, but we weren't able to load friends
};


typedef NS_ENUM(NSInteger, VFindFriendsTableType)
{
    VFindFriendsTableTypeFacebook,      ///< Table used to display Facebook friends
    VFindFriendsTableTypeTwitter,       ///< Table used to display Twitter friends
    VFindFriendsTableTypeAddressBook    ///< Table used to display friends from the Address Book
};

@class VFindFriendsTableView;


/**
 Base class for table view controllers 
 in the find friends feature
 */
@interface VFindFriendsTableViewController : UIViewController

@property (nonatomic, readonly) VFindFriendsTableView      *tableView; ///< Returns the same object as the "view" property
@property (nonatomic, readonly) VFindFriendsTableViewState  state;
@property (nonatomic) VFindFriendsTableType findFriendsTableType;
@property (nonatomic)           BOOL                        shouldAutoselectNewFriends; ///< If YES, new friends will be automatically selected as they're displayed

/**
 Not to be called directly. Subclasses should override this method.
 
 @param userInteraction If YES, the user may be prompted to authorize the connection. If NO,
                        the authorization will fail if it can't be accomplished without
                        user interaction.
 */
- (void)connectToSocialNetworkWithPossibleUserInteraction:(BOOL)userInteraction completion:(void(^)(BOOL connected, NSError *error))completionBlock;

/**
 Not to be called directly. Subclasses should override this method.
 
 @param completionBlock Called when the loading operation completes. The array
                        parameter should be an array of VUser objects, or nil
                        if an error occurred, or an empty array if no friends
                        are found.
 */
- (void)loadFriendsFromSocialNetworkWithCompletion:(void (^)(NSArray *, NSError *))completionBlock;

/**
 Returns a set of VUser objects, one for
 each user selected in the table view.
 */
- (NSArray *)selectedUsers;

@end
