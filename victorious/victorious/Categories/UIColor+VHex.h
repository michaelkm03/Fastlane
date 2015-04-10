//
//  UIColor+VHex.h
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (VHex)

+ (UIColor *)v_colorFromHexString:(NSString *)hexString;

- (NSString *)v_hexString;

@end