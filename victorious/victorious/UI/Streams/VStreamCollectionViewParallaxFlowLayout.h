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
 A collection view flow layout that allows for a parallax effect on the header cell
 */
@interface VStreamCollectionViewParallaxFlowLayout : UICollectionViewFlowLayout

/**
 How much parallax effect you want. A value of 0.5 will cause the header cell to scroll
 half as fast as the rest of the collection view.
 */
@property (nonatomic, assign) CGFloat marqueeParallaxRatio;

- (instancetype)initWithStreamDataSource:(VStreamCollectionViewDataSource *)dataSource;

@end
