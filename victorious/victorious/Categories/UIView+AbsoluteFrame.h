//
//  UIView+AbsoluteFrame.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AbsoluteFrame)

/**
    Traverses the subviews of this view to provide an "absolute" frame,
    a frame of a view in relation to the entire screen.
    Internally calls absoluteOriginOfView to find the origin of this view.
 
    @return The frame of the provided view in relation to the entire screen.
 */
- (CGRect)absoluteFrame;

/**
 Traverses the subviews of this view to provide an "absolute" origin,
 the origin of a view in relation to the entire screen.
 
 @return The origin of the provided view in relation to the entire screen.
 */
- (CGPoint)absoluteOrigin;

@end
