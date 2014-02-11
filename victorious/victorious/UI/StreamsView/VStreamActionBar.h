//
//  VStreamActionBar.h
//  victorious
//
//  Created by Will Long on 2/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence, VAnswer;

extern NSInteger const VStreamActionBarHeight;

@protocol VCreateSequenceDelegate <NSObject>

- (void)finishedPollOrQuizWithAnswer:(VAnswer*)answer;
- (void)throwTomato;
- (void)blowKiss;

@end

@interface VStreamActionBar : UIView

@property (strong, nonatomic) VSequence* currentSequence;
@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;

+ (instancetype)viewFromNib;

@end
