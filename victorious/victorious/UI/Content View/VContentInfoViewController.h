//
//  VContentInfoViewController.h
//  victorious
//
//  Created by Will Long on 7/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSequence;

#import <UIKit/UIKit.h>

@protocol VContentInfoDelegate <NSObject>

- (void)didCloseFromInfo;
- (void)willCommentFromInfo;

@end

@interface VContentInfoViewController : UIViewController

@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic, weak) id<VContentInfoDelegate> delegate;

+ (VContentInfoViewController *)sharedInstance;

@end
