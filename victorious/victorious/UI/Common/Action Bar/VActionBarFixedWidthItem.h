//
//  VActionBarFixedWidthItem.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VActionBarFixedWidthItem : UIView

/**
 *  A fixed width item for use in layout of VActionBar's action items.
 */
+ (VActionBarFixedWidthItem *)fixedWidthItemWithWidth:(CGFloat)width;

/**
 *  The fixed width this actionBarItem should take up.
 */
@property (nonatomic, assign, readonly) CGFloat width;

@end
