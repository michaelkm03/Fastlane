//
//  VKeyboardBarViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImagePickerViewController.h"

@class VKeyboardBarViewController;

@protocol VKeyboardBarDelegate <NSObject>

@required

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL mediaExtension:(NSString *)mediaExtension;
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar wouldLikeToBeResizedToHeight:(CGFloat)height;

@end

@interface VKeyboardBarViewController : UIViewController

@property (nonatomic, weak)   id<VKeyboardBarDelegate>  delegate;
@property (nonatomic, strong) NSAttributedString       *textViewText;
@property (nonatomic, weak)   IBOutlet UILabel         *promptLabel;

- (IBAction)cameraPressed:(id)sender;
- (BOOL)becomeFirstResponder; ///< Tells the keyboard bar view controller to make its internal text view the first responder

@end
