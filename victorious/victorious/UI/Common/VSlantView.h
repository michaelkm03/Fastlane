//
//  VSlantView.h
//  victorious
//
//  Created by Michael Sena on 4/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VSlantView draws a slanted view from either left to right 
 *  as follows:
 *
 *  *
 *  **
 *  ***
 *  ****
 *
 *  Use slantColor to color the slant shape.
 */
@interface VSlantView : UIView

@property (nonatomic, strong) UIColor *slantColor;

@end
