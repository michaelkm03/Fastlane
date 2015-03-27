//
//  VBackgroundContainer.h
//  victorious
//
//  Created by Michael Sena on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class UIView;

/**
 *  VBackgroundContainer defines a common interface for any object to provide a container view for a background view.
 */
@protocol VBackgroundContainer <NSObject>

@optional

/**
 *  Protocol conformers should implement this method if they are able to support a VBackground being added to the returned view's hierarchy.
 *
 *  @return A view that can become the superview of a new background.
 */
- (UIView *)v_backgroundContainer;

@end
