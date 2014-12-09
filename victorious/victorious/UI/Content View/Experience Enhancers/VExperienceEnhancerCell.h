//
//  VExperienceEnhancerCell.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VExperienceEnhancerCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSString *experienceEnhancerTitle;
@property (nonatomic, strong) UIImage *experienceEnhancerIcon;
@property (nonatomic, assign) BOOL isLocked;

@end
