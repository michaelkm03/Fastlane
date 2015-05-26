//
//  VTimeSinceWidget.h
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

@class VSequence;

/**
 *  VTimeSinceWidget displays the elapsed time since a particular 
 *  sequence was posted.
 */
@interface VTimeSinceWidget : UIView <VHasManagedDependencies>

/**
 *  The sequence represented by this time since view.
 */
@property (nonatomic, strong) VSequence *sequence;

@end
