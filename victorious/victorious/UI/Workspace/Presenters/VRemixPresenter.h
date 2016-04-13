//
//  VRemixPresenter.h
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

@class VSequence;

@interface VRemixPresenter : VAbstractPresenter

/**
 *  Designate initializer for VRemixPresenter. Must pass in a valid sequenceToRemix.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                          sequenceToRemix:(VSequence *)sequenceToRemix NS_DESIGNATED_INITIALIZER;

@end
