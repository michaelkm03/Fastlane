//
//  VContentPollBallotCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollBallotCell.h"

@interface VContentPollBallotCell ()

@property (weak, nonatomic) IBOutlet UILabel *answerALabel;
@property (weak, nonatomic) IBOutlet UILabel *answerBLabel;

@end

@implementation VContentPollBallotCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 60);
}

- (void)setAnswerA:(NSString *)answerA
{
    _answerA = [answerA copy];
    self.answerALabel.text = _answerA;
}

- (void)setAnswerB:(NSString *)answerB
{
    _answerB = [answerB copy];
    self.answerBLabel.text = _answerB;
}

@end
