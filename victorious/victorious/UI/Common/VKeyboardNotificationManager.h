//
//  VKeyboardNotificationManager.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A Change block for keyboard changes. CGRects should be converted from window coordinates via [someView convertRect:keyboardRect fromView:nil].
 *
 *  @param keyboardFrameBegin Extracted from userInfo UIKeyboardFrameBeginUserInfoKey.
 *  @param keyboardFrameEnd   Extracted from userInfo UIKeyboardFrameEndUserInfoKey.
 *  @param animationDuration  Use with "animateWithDuration:" methods.
 *  @param animationCurve     Apply to your UIViewAnimationOptions with (animationCurve << 16)
 */
typedef void (^VKeyboardManagerKeyboardChangeBlock) (CGRect keyboardFrameBegin,
                                                     CGRect keyboardFrameEnd,
                                                     NSTimeInterval animationDuration,
                                                     UIViewAnimationCurve animationCurve);

@interface VKeyboardNotificationManager : NSObject

/**
 *  Initializer for VKeyboardManager. Blocks will be called when appropriate.
 */
- (instancetype)initWithKeyboardWillShowBlock:(VKeyboardManagerKeyboardChangeBlock)willShowBlock
                                willHideBlock:(VKeyboardManagerKeyboardChangeBlock)willHideBlock
                         willChangeFrameBlock:(VKeyboardManagerKeyboardChangeBlock)willChangeFrameBlock NS_DESIGNATED_INITIALIZER;

@end
