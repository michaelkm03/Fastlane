//
//  VContentPollBallotCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollBallotCell.h"

#import "UIImage+ImageCreation.h"

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

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *unselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.answerAButton.backgroundColor = unselectedColor;
    self.answerBButton.backgroundColor = unselectedColor;
    
    self.answerAButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.answerBButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
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

- (void)setVotingDisabledWithFavoredBallot:(VBallot)ballot
                                  animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
        {
            [self setVotingDisabledWithFavoredBallot:ballot];
        }
                         completion:nil];
    }
    else
    {
        [self setVotingDisabledWithFavoredBallot:ballot];
    }
}

- (void)setVotingDisabledWithFavoredBallot:(VBallot)ballot
{
    self.answerAButton.enabled = NO;
    self.answerBButton.enabled = NO;
    
    UIColor *selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    UIColor *unselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.answerAButton.backgroundColor = (ballot == VBallotA) ? selectedColor : unselectedColor;
    self.answerBButton.backgroundColor = (ballot == VBallotB) ? selectedColor : unselectedColor;
}

#pragma mark - IBActions

- (IBAction)selectedAnswerA:(id)sender
{
    if (self.answerASelectionHandler)
    {
        self.answerASelectionHandler();
    }
}

- (IBAction)selectedAnswerB:(id)sender
{
    if (self.answerBSelectionHandler)
    {
        self.answerBSelectionHandler();
    }
}

@end
