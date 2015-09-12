//
//  VPollAnswerReceiver.h
//  victorious
//
//  Created by Patrick Lynch on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@protocol VPollAnswerReceiver <NSObject>

- (void)setAnswerAPercentage:(CGFloat)answerAPercentage animated:(BOOL)animated;
- (void)setAnswerBPercentage:(CGFloat)answerBPercentage animated:(BOOL)animated;
- (void)setAnswerAIsFavored:(BOOL)answerAIsFavored;
- (void)setAnswerBIsFavored:(BOOL)answerBIsFavored;

@end