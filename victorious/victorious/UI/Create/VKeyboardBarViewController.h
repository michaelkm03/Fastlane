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

@end

@interface VKeyboardBarViewController : UIViewController
@property (nonatomic, weak) id<VKeyboardBarDelegate> delegate;
@property (weak, nonatomic, readonly) IBOutlet UITextField *textField;

- (IBAction)cameraPressed:(id)sender;

@end
