//
//  VKeyboardBarViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VKeyboardBarViewController;

@protocol VKeyboardBarDelegate <NSObject>

@required
@optional
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL;
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar wouldLikeToBeResizedToHeight:(CGFloat)height;
- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar;
@end

@interface VKeyboardBarViewController : UIViewController

@property (nonatomic, weak, readonly) IBOutlet UITextView *textView;
@property (nonatomic, weak)   id<VKeyboardBarDelegate>  delegate;
@property (nonatomic, strong) NSAttributedString       *textViewText;
@property (nonatomic, weak)   IBOutlet UILabel         *promptLabel;
@property (nonatomic)         BOOL                      hideAccessoryBar;
@property (nonatomic)         BOOL                      sendButtonEnabled;

/**
 If YES (default), text and media will be cleared automatically after the 
 keyboardBar:didComposeWithText:mediaURL: delegate method is called
 */
@property (nonatomic) BOOL shouldAutoClearOnCompose;

- (IBAction)cameraPressed:(id)sender;
- (void)clearKeyboardBar; ///< Clears all text and media from the keyboard bar

@end
