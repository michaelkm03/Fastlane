//
//  VUserCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

@class VUser, VDependencyManager;

/**
 A collection view cell designed to display profile, name and other information about a user.
 Also includes a follow toggle button so that the user can be followed or unfollowed when
 displayed in a collection view.
 */
@interface VUserCell : VBaseCollectionViewCell

- (void)setUser:(VUser *)user;
- (void)updateFollowingAnimated:(BOOL)animated;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
