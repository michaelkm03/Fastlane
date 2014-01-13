//
//  VComposeViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSequence;

@protocol VComposeMessageDelegate <NSObject>
- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension;
@end

@interface VComposeViewController : UIViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) id<VComposeMessageDelegate> delegate;
@end

