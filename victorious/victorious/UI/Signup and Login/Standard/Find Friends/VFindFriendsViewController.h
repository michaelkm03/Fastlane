//
//  VFindFriendsViewController.h
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDependencyManager+VAccessoryScreens.h"

@class VDependencyManager;

@interface VFindFriendsViewController : UIViewController <VAccessoryNavigationSource>

@property (nonatomic) BOOL shouldAutoselectNewFriends; ///< If YES, new friends will be automatically selected as they're displayed

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
