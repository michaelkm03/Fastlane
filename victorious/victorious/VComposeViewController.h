//
//  VComposeViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSequence;

@protocol VComposeMessageDelegate <NSObject>
@required
- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL;
@end

@interface VComposeViewController : UIViewController
@property (nonatomic, weak) id<VComposeMessageDelegate> delegate;
@end

