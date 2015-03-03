//
//  VSolidColorBackground.h
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBackground.h"

extern NSString * const VSolidColorBackgroundColorKey;

/**
 *  A background that is simply a solid color.
 */
@interface VSolidColorBackground : VBackground

/**
 *  The background color of this view.
 */
@property (nonatomic, readonly) UIColor *backgroundColor;

@end
