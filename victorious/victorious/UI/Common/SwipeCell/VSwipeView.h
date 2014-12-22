//
//  VSwipeView.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSwipeView : UIView

/**
 Area to hit test for touch points that may extend beyond the parent view's bounds.
 Set this area with a CGRect that will be active in such a case.
 */
@property (nonatomic, assign) CGRect activeOutOfBoundsArea;

@end
