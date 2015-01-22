//
//  UIColor+Brightness.h
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Brightness)

- (UIColor *)v_colorDarkenedBy:(CGFloat)amount;
- (UIColor *)v_colorLightenedBy:(CGFloat)amount;

@end
