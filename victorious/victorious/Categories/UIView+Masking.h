//
//  UIView+Masking.h
//  victorious
//
//  Created by Gary Philipp on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Masking)

- (void)maskWithImage:(UIImage *)mask;
- (void)maskWithImage:(UIImage *)mask size:(CGSize)maskSize;
- (void)removeMask;

@end
