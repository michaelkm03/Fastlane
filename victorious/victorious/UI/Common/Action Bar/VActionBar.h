//
//  VActionBar.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VActionBarFlexibleSpaceItem;
@class VActionBarFixedWidthItem;

/**
 *  VActionBar lays out action items in a UIToolBar like API.
 *
 *  Ignores margins.
 *
 *  VActionBar determines the width of item as follows:
 *      1. If any width constraints are installed on the view that don't reference 
 *         any other views. (i.e. secondItem should be nil.)
 *      2. The intrinsic content size width.
 *      3. Defaults to 44 pt width
 *
 *
 */
@interface VActionBar : UIView

/**
 *  A flexible space item for use in layout of VActionBar's action items.
 */
+ (VActionBarFlexibleSpaceItem *)flexibleSpaceItem;

/**
 *  A fixed width item for use in layout of VActionBar's action items.
 */
+ (VActionBarFixedWidthItem *)fixedWidthItemWithWidth:(CGFloat)width;

/**
 *  The items to distribute over the action bar.
 *
 *  Each item should only appear once in the array. A view appearing twice in the array is undefined.
 *
 */
@property (nonatomic, copy) NSArray *actionItems;

@end


@interface VActionBarFlexibleSpaceItem : UIView

@end

@interface VActionBarFixedWidthItem : UIView

@property (nonatomic, assign) CGFloat width;

@end
