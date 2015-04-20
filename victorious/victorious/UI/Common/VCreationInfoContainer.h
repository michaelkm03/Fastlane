//
//  VCreationInfoContainer.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VActionBarTruncation.h"

@class VSequence;

/**
 *  VCreationInfoContainer is used to display information about the creator
 *  of a given sequence. Will show "remixed/giffed" by text when the content is derivative.
 *
 *  VCreationInfoContainer implements VActionBarTruncation and can safely be truncated.
 */
@interface VCreationInfoContainer : UIView <VHasManagedDependencies, VActionBarTruncation>

/**
 *  The sequence that this creation infor container view represents.
 */
@property (nonatomic, strong) VSequence *sequence;

@end
