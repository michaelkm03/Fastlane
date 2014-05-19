//
//  VActivityIndicatorView.h
//  victorious
//
//  Created by Josh Hinman on 5/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A UIActivityIndicatorView in the middle with a nice 50% gray rounded background
 */
@interface VActivityIndicatorView : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end
