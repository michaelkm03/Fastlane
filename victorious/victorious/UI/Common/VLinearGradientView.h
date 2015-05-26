//
//  VLinearGradientView.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A wrapper around CAGRadientLayer.
 */
@interface VLinearGradientView : UIView

/**
 *  An array of UIColors defining the colors of each gradient 
 *  stop. Defaults to nil.
 */
- (void)setColors:(NSArray *)colors;

/**
 *  An optional arry of NSNumber objects. See CAGradientLayer
 */
@property (nonatomic, copy) NSArray *locations;

@end
