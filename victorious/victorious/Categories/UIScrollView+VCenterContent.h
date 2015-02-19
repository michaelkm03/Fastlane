//
//  UIScrollView+VCenterContent.h
//  victorious
//
//  Created by Michael Sena on 2/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VCenterContent)

/**
 *  Centers the content of a scrollview adjusting either the x or y component of the contentoffset to center the content.
 *  This should only be called when initially laying out your scrollview. Avoid using during scrolling.
 *
 *  @param animated Whether or not to animate.
 */
- (void)v_centerContentAnimated:(BOOL)animated;

@end
