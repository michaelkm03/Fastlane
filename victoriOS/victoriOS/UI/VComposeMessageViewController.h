//
//  VComposeMessageViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VComposeMessageDelegate <NSObject>
- (void)didComposeWithText:(NSString*)text data:(NSData*)data extension:(NSString*)extension;
@end

@interface VComposeMessageViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) id<VComposeMessageDelegate> delegate;

@end
