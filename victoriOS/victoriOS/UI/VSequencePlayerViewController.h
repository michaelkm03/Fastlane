//
//  VSequencePlayerViewController.h
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSequence.h"

@interface VSequencePlayerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, strong) VSequence* sequence;

- (instancetype)initWithSequence:(VSequence*)sequence;
@end
