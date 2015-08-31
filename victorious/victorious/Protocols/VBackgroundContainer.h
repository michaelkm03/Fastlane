//
//  VBackgroundContainer.h
//  victorious
//
//  Created by Michael Sena on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class UIView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  VBackgroundContainer defines a common interface for any object to provide a container view for a background view.
 */
@protocol VBackgroundContainer <NSObject>

@optional

/**
 *  Protocol conformers implement this method to provide a background container view. Callers will be able to add 
 *  backgrounds to this view.
 *
 *  @return A view that can become the superview of a new background. Return nil if no background can be added or is
 *  required.
 */
- (UIView *)backgroundContainerView;

/**
 *  Protocol conformers implement this method to allow a loading view to be added to be added to a particular view hierarchy.
 */
- (UIView *)loadingBackgroundContainerView;

@end

NS_ASSUME_NONNULL_END
