//
//  VContentViewBaseLayout.h
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const VContentViewBaseLayoutDecelerationLocationDesiredContentOffset;
UIKIT_EXTERN NSString * const VContentViewBaseLayoutDecelerationLocationThresholdAbove;
UIKIT_EXTERN NSString * const VContentViewBaseLayoutDecelerationLocationThresholdBelow;

@interface VContentViewBaseLayout : UICollectionViewFlowLayout

- (NSArray *)desiredDecelerationLocations;

@end
