//
//  VRepostButtonController.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@interface VActionButtonAnimationController : NSObject

/**
 Sets the button's `selected` property according to the `selected` parameter
 and animates a bouncy scale up animation if the button wasn't selected
 previously.
 */
- (void)setButton:(UIButton *)button selected:(BOOL)selected;

@end
