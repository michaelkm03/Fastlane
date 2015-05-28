//
//  UIView+VViewRendering.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ViewRenderingCompletion) (UIImage *image);

@interface UIView (VViewRendering)

- (void)v_renderViewWithCompletion:(ViewRenderingCompletion)completion;

@end
