//
//  VBadgeBackgroundView.h
//  victorious
//
//  Created by Josh Hinman on 12/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

/**
 Draws a rounded rect suitable for being
 the background of a numerical badge
 */
@interface VBadgeBackgroundView : UIView

@property (nonatomic, strong) IBInspectable UIColor *color; ///< The fill color of the rounded rect

@end
