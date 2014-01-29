//
//  VComposeViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImagePickerController.h"

@protocol VComposeMessageDelegate <NSObject>
@required
- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL;
@end

@interface VComposeViewController : UIViewController
@property (nonatomic, weak) id<VComposeMessageDelegate> delegate;
@property (weak, nonatomic, readonly) IBOutlet UITextField *textField;
@end

