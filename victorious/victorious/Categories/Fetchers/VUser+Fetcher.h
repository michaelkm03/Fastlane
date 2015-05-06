//
//  VUser+Fetcher.h
//  victorious
//
//  Created by Will Long on 5/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser.h"

@interface VUser (Fetcher)

/**
 Returns whether or not this user is the owner (creator) of the this app.
 */
- (BOOL)isOwner;

@end
