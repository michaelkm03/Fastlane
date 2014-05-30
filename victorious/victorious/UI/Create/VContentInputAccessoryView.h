//
//  VContentInputAccessoryView.h
//  victorious
//
//  Created by Josh Hinman on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A toolbar that displays a character count and a hashtag button.
 */
@interface VContentInputAccessoryView : UIView

@property (nonatomic, weak)           id<UITextInput>  textInputView; ///< The text input view for which the receiver is an input accessory.
@property (nonatomic, weak, readonly) UIBarButtonItem *hashtagButton; ///< Pressing this button inserts a hashtag into the textInputView

@end
