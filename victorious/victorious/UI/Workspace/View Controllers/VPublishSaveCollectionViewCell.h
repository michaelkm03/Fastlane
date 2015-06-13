//
//  VPublishSaveCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VDependencyManager;

@interface VPublishSaveCollectionViewCell : VBaseCollectionViewCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds andSectionInsets:(UIEdgeInsets)insets;

@property (nonatomic, weak) IBOutlet UISwitch *cameraRollSwitch;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
