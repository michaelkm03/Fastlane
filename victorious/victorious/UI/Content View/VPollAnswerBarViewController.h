//
//  VPollAnswerBarViewController.h
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAnimation.h"

@class VSequence, VAnswer;

@protocol VPollAnswerBarDelegate <NSObject>
@required
- (void)answeredPollWithAnswerId:(NSNumber*)answerId;
@end

@interface VPollAnswerBarViewController : UIViewController <VAnimation>

@property (strong, nonatomic) VSequence* sequence;
@property (strong, nonatomic) NSArray* answers;
@property (weak, nonatomic) id<VPollAnswerBarDelegate> delegate;

+ (VPollAnswerBarViewController *)sharedInstance;

@end
