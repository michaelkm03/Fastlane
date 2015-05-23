//
//  UIView+AbsoluteFrame.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    Convenience methods for getting the frame of a UI element
    in relation to the window that contains it
 */
@interface UIView (AbsoluteFrame)

/**
    Internally calls convertRect:toView:
 
    @return The frame of the provided view in relation to the entire screen.
 */
- (CGRect)absoluteFrame;

/**
 Internally calls convertPoint:toView:
 
 @return The origin of the provided view in relation to the entire screen.
 */
- (CGPoint)absoluteOrigin;

@end
