//
//  UIView+VViewRendering.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    Describes a block that delivers a screenshot
    of the view after it's been rendered
 */
typedef void (^ViewRenderingCompletion) (UIImage *image);

/**
    A convenience class for speedily rendering a screenshot of a view
 */
@interface UIView (VViewRendering)

/**
    Dispaches on the main queue, renders the view,
    and provides it to the completion block
 */
- (void)v_renderViewWithCompletion:(ViewRenderingCompletion)completion;

@end
