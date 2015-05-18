//
//  VStreamHeaderComment.h
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VSequence;

/**
 *  A Stream header with a comment button on the right.
 */
@interface VStreamHeaderComment : UIView <VHasManagedDependencies>

/**
 *  The sequence for this header to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

@end
