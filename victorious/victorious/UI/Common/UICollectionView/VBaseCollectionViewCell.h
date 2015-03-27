//
//  VBaseCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"
#import "VSwipeCollectionViewCell.h"
#import "VBackgroundHost.h"

@class VDependencyManager;

/**
 *  Implements sensible defaults of VSharedCollectionReusableViewMethods. All CollectionViewCell subclasses should subclass VBaseCollectionViewCell.
 */
@interface VBaseCollectionViewCell : VSwipeCollectionViewCell <VSharedCollectionReusableViewMethods, VBackgroundHost>

/**
 A dependencyManager that subclasses of this class can use to modify cell appearance.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
