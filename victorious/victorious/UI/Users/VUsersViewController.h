//
//  VUsersViewController.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VUsersDataSource.h"

/**
 The possible context identifier that this view is presented as
 */
typedef NS_ENUM( NSInteger, VUsersViewContext )
{
    VUsersViewContextNone, // Default value
    VUsersViewContextFollowers, // Set when presented as followers list
    VUsersViewContextFollowing, // Set when presented as following list
    VUsersViewContextLikers // Set when presented as likers list
};

/**
 A generic collection view that is designed to display lists of users
 in a unified way through the application.  All visual style and basic collection
 view functionality is handled within this class.  All that is needed is to set the
 `usersDataSource` to an object conforming to `VUserDataSource` and this view
 controller will refresh and read the list of users during the normal course of its
 life cycle.
 */
@interface VUsersViewController : UIViewController <VHasManagedDependencies>

/**
 An object that loads and provides a list of users to display in the collection view.
 */
@property (nonatomic, strong) id<VUsersDataSource> usersDataSource;
@property (nonatomic, assign) VUsersViewContext usersViewContext;

@end
