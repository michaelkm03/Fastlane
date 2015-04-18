//
//  VUserProfileHeader.h
//  victorious
//
//  Created by Patrick Lynch on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

@protocol VUserProfileHeaderDelegate <NSObject>

- (void)editProfileHandler;

- (void)followerHandler;

- (void)followingHandler;

@end

@protocol VUserProfileHeader <NSObject>

- (void)update;

- (void)setIsLoading:(BOOL)isLoading;

@property (nonatomic, weak) id<VUserProfileHeaderDelegate> delegate;

@property (nonatomic, assign) BOOL isFollowingUser;

@property (nonatomic, strong) VUser *user;

@end
