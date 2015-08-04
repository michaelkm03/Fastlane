//
//  VKeyboardInputAccessoryView.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUserTaggingTextStorageDelegate.h"

typedef NS_ENUM(NSInteger, VKeyboardBarAttachmentType)
{
    VKeyboardBarAttachmentTypeImage,
    VKeyboardBarAttachmentTypeVideo,
    VKeyboardBarAttachmentTypeGIF,
};

@class VKeyboardInputAccessoryView, VDependencyManager;

@protocol VKeyboardInputAccessoryViewDelegate <NSObject, VUserTaggingTextStorageDelegate>

/**
 *  Notifies the delegate of the input accessory view that the send button has been pressed.
 *
 *  @param inputAccessoryView The input accessory view that the send button belongs to.
 */
- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView;

/**
 *  Notifies the delegate that the user selected a particular attachment type.
 */
- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
            selectedAttachmentType:(VKeyboardBarAttachmentType)attachmentType;

/**
 *  Notifies the delegate that the user tapped the thumbnail of the currently attached media.
 */
- (void)keyboardInputAccessoryViewWantsToClearMedia:(VKeyboardInputAccessoryView *)inputAccessoryView;

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
 *  The VKeyboardInputAccessoryView manages a message composition interface. It contains an attachment button, a textView 
 *  and a send button. As the textview's text changes the VKeyboardInputAccessoryView will attempt to resize itself to 
 *  accomodate the text. After reaching the maximum allowed growing space as defined by it's delegate the 
 *  VKeyboardInputAccessoryView will stop growing and let the textView scroll it's content. This behavior is similar to 
 *  the messages app as it appeared in iOS7.
 */
@interface VKeyboardInputAccessoryView : UIView

/**
 *  A convenience factory method for creating VKeyboardInputAccessoryViews.
 *
 *  @return A newly instantiated inputAccessoryView.
 */
+ (VKeyboardInputAccessoryView *)defaultInputAccessoryViewWithDependencyManager:(VDependencyManager *)dependencyManager;

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
 *  Use this property to override the default behavior of the attachments bar and force it to hidden.
 */
@property (nonatomic, assign, getter=isAttachmentsBarHidden) BOOL attachmentsBarHidden;

/**
 *  The selected thumbnail image for the current attachment. Setting this to nil will restore the original placeholder image.
 */
- (void)setSelectedThumbnail:(UIImage *)selectedThumbnail;

/**
 *  Call this to stop editing.
 *
 *  @return Returns whether or not the view really stopped editing and resigned first responder.
 */
- (BOOL)stopEditing;

@property (nonatomic, weak) UITextView *editingTextView;

/**
 *  Call this to have the textView embedded in this view to become first responder.
 */
- (void)startEditing;

/**
 *  Used to infrom callers on the current editing state.
 *
 *  @param return Whether or not this is editing.
 */
- (BOOL)isEditing;

/**
 *  Call this to clear out text and media input on this view.
 */
- (void)clearTextAndResign;
- (void)replyToUser:(VUser *)user;

@end

@interface VKeyboardInputAccessoryView (keyboardSize)

/**
 *  The keyboardInputAccessoryView is taller than it's contents actually require, this rect represents the actually visible portion of the 
 *  window covered by this view. Note touches that do not intersect this rect are passed through.
 */
- (CGRect)obscuredRectInWindow:(UIWindow *)window;

@end
