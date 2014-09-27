//
//  VCollapsingFlowLayout.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewBaseLayout.h"

@interface VContentViewVideoLayout : VContentViewBaseLayout

/**
 *  The size of the header.
 */
@property (nonatomic, assign, readonly) CGFloat dropDownHeaderMiniumHeight;

/**
 *  The size of the contentView in it's full state. Note: does not update or reflect the current state when shrinking/floating.
 */
@property (nonatomic, assign) CGSize sizeForContentView;

/**
 *  The size of RealTimeComments. Note: Does not update with real time comments shrinking.
 */
@property (nonatomic, assign) CGSize sizeForRealTimeComentsView;

/**
 *  The catch point at which to start shrinking the cell at indexpath 0,0.
 */
@property (nonatomic, assign) CGFloat catchPoint;

@end
