//
//  VUserProfileHeader.h
//  victorious
//
//  Created by Patrick Lynch on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

typedef NS_ENUM( NSInteger, VUserProfileHeaderState)
{
    /**
     If the user is viewing their own profile, requiring extra utilty buttons for
     editing functionality.
     */
    VUserProfileHeaderStateCurrentUser,
    /**
     If the loggedin user is following the profile of the user that is being displayed in this header.
     */
    VUserProfileHeaderStateFollowingUser,
    /**
     If the loggedin user is NOT following the profile of the user that is being displayed in this header.
     */
    VUserProfileHeaderStateNotFollowingUser
};

/**
 Responds to user input actions taken in VUserProfileHeader components.
 */
@protocol VUserProfileHeaderDelegate <NSObject>

/**
 While any user's profile (including his or her own), the logged-in user selected
 to view that user's followers.
 */
- (void)followerHandler;

/**
 While any user's profile (including his or her own), the logged-in user selected
 to view users that that user is following.
 */
- (void)followingHandler;

/**
 While viewing his or her own profile, the logged-in user did select option to edit it.
 */
- (void)primaryActionHandler;

@end

/**
 A subcomponent of a user profile stream that exists in the fits cell of the stream
 that displays user profile data and provides UI to take furhter action to display
 more information about the user.
 */
@protocol VUserProfileHeader <NSObject>

/**
 Delegate that will receive forwarded input from the user.
 */
@property (nonatomic, weak) id<VUserProfileHeaderDelegate> delegate;

/**
 The user to display in this instance of the header.
 */
@property (nonatomic, strong) VUser *user;

/**
 Show 
 */
@property (nonatomic, assign) BOOL isLoading;

/**
 The height to which a containing stream cell must be sized in order to properly
 display this header view.
 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;

/**
 Gets/sets the state of the profile header into one of the available values for
 VUserProfileHeaderState.
 */
@property (nonatomic, assign) VUserProfileHeaderState state;

- (UIView *)floatingProfileImage;

@end
