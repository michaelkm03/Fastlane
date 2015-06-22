//
//  VLikersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VUsersDataSource.h"

@class VSequence;

/**
 An object designed to be plugged into VUsersViewController's collection view
 to display a list of users that like the sequence provided.  This class handles
 loading the data and making it available for display.
 */
@interface VLikersDataSource : NSObject <VUsersDataSource>

/**
 Initializer requiring a VSequence obejct from which to load likers.
 */
- (instancetype)initWithSequence:(VSequence *)sequence NS_DESIGNATED_INITIALIZER;

@end
