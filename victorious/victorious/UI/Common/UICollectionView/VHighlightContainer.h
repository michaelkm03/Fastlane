//
//  VHighlightContainer.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGFloat kHighlightViewAlpha = 0.6f;
static const NSTimeInterval kHighlightTimeInterval = 0.1;

/**
 *  VHighlightContainer defines a common interface for any cell to provide a container view for a highlight view.
 */
@protocol VHighlightContainer <NSObject>

@optional

/**
 *  Protocol conformers implement this method to provide a highlight container view. Callers will be able to add
 *  a highlight view to this view.
 *
 *  @return A view that can become the superview of a new highlight view. Return nil if no highlight can be added or is
 *  required.
 */
- (UIView *)highlightContainerView;

@end
