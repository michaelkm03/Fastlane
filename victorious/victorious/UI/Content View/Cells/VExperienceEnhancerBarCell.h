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

@property (nonatomic, weak, readonly) VExperienceEnhancerBar *experienceEnhancerBar;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
