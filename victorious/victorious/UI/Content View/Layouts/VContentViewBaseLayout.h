//
//  VContentViewBaseLayout.h
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const VContentViewBaseLayoutDecelerationLocationDesiredContentOffset;
extern NSString * const VContentViewBaseLayoutDecelerationLocationThresholdAbove;
extern NSString * const VContentViewBaseLayoutDecelerationLocationThresholdBelow;

@interface VContentViewBaseLayout : UICollectionViewFlowLayout

- (NSArray *)desiredDecelerationLocations;

@end
