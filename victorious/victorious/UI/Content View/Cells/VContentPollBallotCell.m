//
//  VContentPollBallotCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollBallotCell.h"

// Theme
#import "VThemeManager.h"

@interface VContentPollBallotCell ()

@property (weak, nonatomic) IBOutlet UIButton *answerAButton;
@property (weak, nonatomic) IBOutlet UIButton *answerBButton;

@end

@implementation VContentPollBallotCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 60);
}

#pragma mark - Property Accessors

- (void)setAnswerA:(NSString *)answerA
{
    _answerA = [answerA copy];
    [self.answerAButton setTitle:_answerA
                        forState:UIControlStateNormal];
}

- (void)setAnswerB:(NSString *)answerB
{
    _answerB = [answerB copy];
    [self.answerBButton setTitle:_answerB
                       forState:UIControlStateNormal];
}

#pragma mark - Public Methods

- (void)setVotingDisabledWithAnswerAFavored:(BOOL)answerAFavored
{
    self.answerAButton.enabled = NO;
    self.answerBButton.enabled = NO;
    
    self.answerAButton.backgroundColor = answerAFavored ? [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.answerBButton.backgroundColor = answerAFavored ? [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

@end
