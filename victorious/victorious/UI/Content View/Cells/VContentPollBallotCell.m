//
//  VContentPollBallotCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollBallotCell.h"

@interface VContentPollBallotCell ()

@property (weak, nonatomic) IBOutlet UIButton *answerAButton;
@property (weak, nonatomic) IBOutlet UIButton *anserBButton;

@end

@implementation VContentPollBallotCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 60);
}

- (void)setAnswerA:(NSString *)answerA
{
    _answerA = [answerA copy];
    [self.answerAButton setTitle:_answerA
                        forState:UIControlStateNormal];
}

- (void)setAnswerB:(NSString *)answerB
{
    _answerB = [answerB copy];
    [self.anserBButton setTitle:_answerB
                       forState:UIControlStateNormal];
}

@end
