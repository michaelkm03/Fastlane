//
//  VKeyboardInputAccessoryView.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKeyboardInputAccessoryView;

extern NSString * const VInputAccessoryViewKeyboardFrameDidChangeNotification;

extern const CGFloat VInputAccessoryViewDesiredMinimumHeight;

/**
 *  !!!ATTENTION!!!
 *  !!!ATTENTION!!!
 *  Need to provide one of these on your UIViewController that controls the superview of the keyboardInputAccessoryView.
 *  !!!ATTENTION!!!
 *  !!!ATTENTION!!!
 */
@interface VInputAccessoryView : UIView

@end

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

@optional

/**
 *  Called when the text is cleared.
 */
- (void)keyboardInputAccessoryViewDidClearInput:(VKeyboardInputAccessoryView *)inpoutAccessoryView;

/**
 *  Called when editing begins.
 */
- (void)keyboardInputAccessoryViewDidBeginEditing:(VKeyboardInputAccessoryView *)inpoutAccessoryView;

/**
 *  Called when editing ends.
 */
- (void)keyboardInputAccessoryViewDidEndEditing:(VKeyboardInputAccessoryView *)inpoutAccessoryView;

/**
 *  Notifies the delegate of a return key press ONLY if that return key is not UIReturnKeyDefault
 *
 *  @param inputAccessoryView The corresponding input accessory view.
 */
- (void)pressedAlternateReturnKeyonKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView;

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
 *  The text the user composed.
 */
@property (nonatomic, readonly) NSString *composedText;

/**
 *  The placeholder text to display when the user has not entered any text in the text view.
 */
@property (nonatomic, strong) NSString *placeholderText;

/**
 *  The selected thumbnail image for the current attachment. Setting this to nil will restore the original placeholder image.
 */
- (void)setSelectedThumbnail:(UIImage *)selectedThumbnail;

/**
 *  Assigning to this will determine the behavior of the return key. UIReturnKeyDefault will allow the user to insert newline characters into the text view while any other return key type will resign first responder status on the text field.
 */
@property (nonatomic, assign) UIReturnKeyType returnKeyType;

- (void)startEditing;
- (void)clearTextAndResign;

@end
