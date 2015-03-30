//
//  VBlurredMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"

@interface VBlurredMarqueeStreamItemCell : VAbstractMarqueeStreamItemCell

@property (nonatomic, assign) CGFloat contentRotation; //Value in range [-1,1] that will cause the content in the cell to rotate such that passing -1 will be a rotation of 180 to the left and 1 will be a rotation of 180 to the right

@end
