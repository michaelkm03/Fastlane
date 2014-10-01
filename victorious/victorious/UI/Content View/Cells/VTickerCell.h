//
//  VTickerCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VTickerCell : VBaseCollectionViewCell

/**
 *  The desired size with no content.
 */
+ (CGSize)desiredSizeForNoRealTimeCommentsWithCollectionViewBounds:(CGRect)bounds;

/**
 *  Assign to this float a value between 0.0f and 1.0f to update the progress bar.
 */
@property (nonatomic, assign) CGFloat progress;

@end
