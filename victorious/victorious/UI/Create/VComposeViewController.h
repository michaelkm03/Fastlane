//
//  VComposeViewController.h
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSequence;

@protocol VComposeMessageDelegate <NSObject>
@required
- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL;
@end

@interface VComposeViewController : UIViewController
@property (nonatomic, weak) id<VComposeMessageDelegate> delegate;
@property (weak, nonatomic, readonly) IBOutlet UITextField *textField;
@end

