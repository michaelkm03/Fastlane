//
//  VFollowingStreamCollectionViewController.h
//  victorious
//
//  Created by Josh Hinman on 12/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VStreamCollectionViewController.h"

/**
 A subclass of VStreamCollectionViewController that: 1) displays a 
 special message and hides the stream if the user is not logged
 in, and 2) displays a special, following-stream-specific message 
 when the stream is empty.
 */
@interface VFollowingStreamCollectionViewController : VStreamCollectionViewController <VHasManagedDependancies>

@end
