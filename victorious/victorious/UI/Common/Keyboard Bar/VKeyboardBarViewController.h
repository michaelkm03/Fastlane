//
//  VKeyboardBarViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserTaggingTextStorageDelegate.h"

@class VKeyboardBarViewController;

@protocol VKeyboardBarDelegate <NSObject, VUserTaggingTextStorageDelegate>
@required
- (CGFloat)initialHeightForKeyboardBar:(VKeyboardBarViewController *)keyboardBar;
@optional
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL;
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar resizeToHeight:(CGFloat)height;
- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar;
- (BOOL)canPerformAuthorizedAction;

@end

@interface VKeyboardBarViewController : UIViewController

@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic, weak)   id<VKeyboardBarDelegate>  delegate;
@property (nonatomic, strong) NSAttributedString       *textViewText;
@property (nonatomic, weak)   IBOutlet UILabel         *promptLabel;
@property (nonatomic)         BOOL                      sendButtonEnabled;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;

/**
 If YES (default), text and media will be cleared automatically after the 
 keyboardBar:didComposeWithText:mediaURL: delegate method is called
 */
@property (nonatomic) BOOL shouldAutoClearOnCompose;

- (IBAction)cameraPressed:(id)sender;
- (void)clearKeyboardBar; ///< Clears all text and media from the keyboard bar
- (void)setHideAccessoryBar:(BOOL)hideAccessoryBar; ///< Hides or shows the input accessory view.

@end
