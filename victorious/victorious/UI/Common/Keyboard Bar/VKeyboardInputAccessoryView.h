//
//  VKeyboardInputAccessoryView.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKeyboardInputAccessoryView;

@protocol VKeyboardInputAccessoryViewDelegate <NSObject>

/**
 *  Notifies the delegate of the input accessory view that the send button has been pressed.
 *
 *  @param inputAccessoryView The input accessory view that the send button belongs to.
 */
- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView;

/**
 *  Notifies the delegate of the input accessory view that the attachment key has been pressed.
 *
 *  @param inputAccessoryView The input accessory view that the attachment key belongs to.
 */
- (void)pressedAttachmentOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView;

/**
 *  Asks the delegate to resize the inputAccessoryView to a specific size. Note that input accessory view will never request a size larger than its maximumAllowedSize property.
 *
 *  @param inpoutAccessoryView The inputAccessoryView that would like to be resized.
 *  @param size                The desired size fo the inputAccessoryView.
 */
- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size;

@end

/**
 *  The VKeyboardInputAccessoryView manages a message composition interface. It contains an attachment button, a textView and a send button. As the textview's text changes the VKeyboardInputAccessoryView will attempt to resize itself to accomodate the text. After reaching the maximum allowed growing space as defined by it's delegate the VKeyboardInputAccessoryView will stop growing and let the textView scroll it's content. This behavior is similar to the messages app as it appeared in iOS7.
 */
@interface VKeyboardInputAccessoryView : UIView

/**
 *  A convenience factory method for creating VKeyboardInputAccessoryViews.
 *
 *  @return A newly instantiated inputAccessoryView.
 */
+ (VKeyboardInputAccessoryView *)defaultInputAccessoryView;

/**
 *  The object that acts as the delegate of the receiving VKeyboardInputAccessoryView.
 */
@property (nonatomic, weak) id <VKeyboardInputAccessoryViewDelegate> delegate;

/**
 *  The placeholder text to display when the user has not entered any text in the text view.
 */
@property (nonatomic, strong) NSString *placeholderText;

/**
 *  The selected thumbnail image for the current attachment.
 */
@property (nonatomic, strong) UIImage *selectedThumbnail;

/**
 *  The maximum allowed size for the inputAcessoryView.
 */
@property (nonatomic, assign) CGSize maximumAllowedSize;

@end
