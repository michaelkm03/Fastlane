//
//  VPlaceholderTextView.h
//  victorious
//
//  Created by Michael Sena on 12/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VPlaceholderTextView maintains a placeholder subview for displaying placeholder text. This subview will be hidden according to the current state of editing. When empty the placeholder is visible at 0.5f alpha, when editing and no text is 0.2f alpha and when text is entered into the textView the placeholder view is hidden.
 */
@interface VPlaceholderTextView : UITextView

@property (nonatomic, copy) NSString *placeholderText; ///< The placeholder text to display in the placeholder view.

- (void)shakeAnimation; ///< Shake it off! (animation + vibrate indicating need to enter text) 

@end
