//
//  VEmotiveBallisticsViewController.h
//  victorious
//
//  Created by Will Long on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAnimation.h"

@interface VEmotiveBallisticsBarViewController : UIViewController <VAnimation>

@property (weak, nonatomic) UIView* target;

+ (VEmotiveBallisticsBarViewController *)sharedInstance;

@end
