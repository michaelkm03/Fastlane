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

- (UIView *)v_backgroundContainer;

@end
