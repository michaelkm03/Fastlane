//
//  VExperienceEnhancerCell.h
//  victorious
//
//  Created by Michael Sena on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VExperienceEnhancerBar, VDependencyManager;

@interface VExperienceEnhancerBarCell : VBaseCollectionViewCell

/**
 *  Must use this method for sizing as this cell relies on dependencyManager for determining its size.
 */
+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
                            dependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, weak, readonly) VExperienceEnhancerBar *experienceEnhancerBar;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
