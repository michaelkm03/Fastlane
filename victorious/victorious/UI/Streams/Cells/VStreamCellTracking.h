//
//  VStreamCellTracking.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequence.h"

/**
 *  Stream cells that conform to this protocol need to return
 *  the appropriate info in order to appropriately track
 *  it's content
 */
@protocol VStreamCellTracking <NSObject>

@required

/**
 Returns the sequence that should be tracked for this cell
 */
- (VSequence *)sequenceToTrack;

@end
