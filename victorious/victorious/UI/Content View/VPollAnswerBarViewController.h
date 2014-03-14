//
//  VPollAnswerBarViewController.h
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAnimation.h"

@class VSequence;

@interface VPollAnswerBarViewController : UIViewController <VAnimation>

@property (strong, nonatomic) VSequence* sequence;
@property (strong, nonatomic) NSArray* answers;
@property (weak, nonatomic) UIView* target;

+ (VPollAnswerBarViewController *)sharedInstance;

@end
