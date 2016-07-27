//
//  VPollResultReceiver.h
//  victorious
//
//  Created by Patrick Lynch on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

/*
 Defines an object that can respond to interaction with a poll view.
 */
@protocol VPollResultReceiver <NSObject>

- (void)setAnswerAPercentage:(CGFloat)answerAPercentage animated:(BOOL)animated;

- (void)setAnswerAIsFavored:(BOOL)answerAIsFavored;

- (void)setAnswerBPercentage:(CGFloat)answerBPercentage animated:(BOOL)animated;

- (void)setAnswerBIsFavored:(BOOL)answerBIsFavored;

- (void)showResults;

- (void)setVoterCountText:(NSString *)text;

@end
