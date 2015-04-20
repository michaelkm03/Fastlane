//
//  VUserProfileHeader.h
//  victorious
//
//  Created by Patrick Lynch on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

/**
 Responds to user input actions taken in VUserProfileHeader components.
 */
@protocol VUserProfileHeaderDelegate <NSObject>

/**
 While viewing his or her own profile, the logged-in user did select option to edit it.
 */
- (void)editProfileHandler;

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

@end

/**
 A subcomponent of a user profile stream that exists in the fits cell of the stream
 that displays user profile data and provides UI to take furhter action to display
 more information about the user.
 */
@protocol VUserProfileHeader <NSObject>

- (void)reload;

/**
 If data is being reloaded in order to re-populated the header view, set to this to YES
 to disable any active UI elements and show some kind of activity indicator.  Set to NO
 to revert back to normal, interactive state when loading is complete or has failed.
 */
- (void)setIsLoading:(BOOL)isLoading;

/**
 Delegate that will receive forwarded input from the user.
 */
@property (nonatomic, weak) id<VUserProfileHeaderDelegate> delegate;

/**
 When following relationships are updated while the user is interacting with various
 elements on this view or its parent stream, set this to YES or NO to update the current
 status of the following relationship with the user displayed in the header.
 */
@property (nonatomic, assign) BOOL isFollowingUser;

/**
 The user to display in this instance of the header.
 */
@property (nonatomic, strong) VUser *user;

/**
 The height to which a containing stream cell must be sized in order to properly
 display this header view.
 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;

@end
