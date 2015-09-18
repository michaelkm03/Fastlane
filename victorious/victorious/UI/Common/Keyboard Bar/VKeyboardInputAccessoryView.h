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

@class VKeyboardInputAccessoryView, VDependencyManager, VSequencePermissions;

NS_ASSUME_NONNULL_BEGIN

@protocol VKeyboardInputAccessoryViewDelegate <NSObject>

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
 *  A user tagging text storage delegate to be informed of user tagging relevant events.
 */
@property (nonatomic, weak) id <VUserTaggingTextStorageDelegate> textStorageDelegate;

/**
 *  The text the user composed.
 */
@property (nonatomic, readonly) NSString *composedText;

/**
 *  Use this property to override the default behavior of the attachments bar and force it to hidden.
 */
@property (nonatomic, assign, getter=isAttachmentsBarHidden) BOOL attachmentsBarHidden;

/**
 *  The sequence permissions of the content that this KeyboardInputAccessoryView is attached to
 */
@property (nonatomic, weak) VSequencePermissions *sequencePermissions;

/**
 *  The selected thumbnail image for the current attachment. Setting this to nil will restore the original placeholder image.
 */
- (void)setSelectedThumbnail:(nullable UIImage *)selectedThumbnail;

/**
 *  Call this to stop editing.
 *
 *  @return Returns whether or not the view really stopped editing and resigned first responder.
 */
- (BOOL)stopEditing;

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

/**
 * Call this whenever you are composing a reply
 */
- (void)setReplyRecipient:(VUser *)user;

@end

@interface VKeyboardInputAccessoryView (keyboardSize)

/**
 *  The keyboardInputAccessoryView is taller than it's contents actually require, this rect represents the actually visible portion of the 
 *  window covered by this view. Note touches that do not intersect this rect are passed through.
 */
- (CGRect)obscuredRectInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
