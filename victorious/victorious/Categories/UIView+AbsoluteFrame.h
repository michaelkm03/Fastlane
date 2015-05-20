//
//  UIView+AbsoluteFrame.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning DOCS, TESTS INCOMPLETE

@interface UIView (AbsoluteFrame)

- (CGRect)absoluteFrameOfView:(UIView *)view;
- (CGPoint)absoluteOriginOfView:(UIView *)view;

@end
