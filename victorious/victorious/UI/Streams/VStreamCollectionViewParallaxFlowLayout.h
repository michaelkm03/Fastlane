//
//  VStreamCollectionViewFlowLayout.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamCollectionViewDataSource.h"
#import "VAbstractMarqueeController.h"

/**
 A collection view flow layout that applies a parallax effect on collection view
 cells which conform to the VParallaxScrolling protocol.
 */
@interface VStreamCollectionViewParallaxFlowLayout : UICollectionViewFlowLayout

@end
