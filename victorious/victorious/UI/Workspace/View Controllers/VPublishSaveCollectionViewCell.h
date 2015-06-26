//
//  VPublishSaveCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VDependencyManager;

/**
    A cell displaying a switch and a prompt.
 */
@interface VPublishSaveCollectionViewCell : VBaseCollectionViewCell

/**
    The optimal height of this cell.
 */
+ (CGFloat)desiredHeight;

@property (nonatomic, weak) IBOutlet UISwitch *cameraRollSwitch; ///< The switch displayed by this cell.
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependency manager used to style this cell.

@end
