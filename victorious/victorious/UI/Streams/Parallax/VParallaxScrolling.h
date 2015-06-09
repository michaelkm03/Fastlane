//
//  VParallaxScrolling.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Conformance to this protocol allows cells to demonstrate a
 parallax effect when they are used in a collection view using
 VStreamCollectionViewParallaxFlowLayout.
 */
@protocol VParallaxScrolling <NSObject>

@required

/**
 How much parallax effect you want. A value of 0.5 will cause the header cell to scroll
 half as fast as the rest of the collection view.
 */
- (CGFloat)parallaxRatio;

@end
