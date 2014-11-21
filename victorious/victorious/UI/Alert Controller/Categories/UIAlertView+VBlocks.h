//
//  UIAlertView+VBlocks.h
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (VBlocks)

/**
 Initialize a new alert view with the given button titles and action blocks.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle onCancelButton:(void(^)(void))cancelBlock otherButtonTitlesAndBlocks:(id)buttonTitle, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Add a button with the given title and action block.
 
 \discussion
 Only call this method on UIAlertView instances that have been initialized via the -initWithTitle:message:cancelButtonTitle:onCancelButton:otherButtonTitleAndBlocks: initializer.
 */
- (void)addButtonWithTitle:(NSString *)title block:(void(^)(void))block;

@end
