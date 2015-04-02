//
//  VContentPollBallotCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollBallotCell.h"

#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"

static NSCache *_sharedSizingCache = nil;
static CGFloat const kMinimumHeight = 60.0f;

@interface VContentPollBallotCell ()

@property (weak, nonatomic) IBOutlet UIButton *answerAButton;
@property (weak, nonatomic) IBOutlet UIButton *answerBButton;

@end

@implementation VContentPollBallotCell

+ (NSCache *)sharedSizingCache
{
    if (_sharedSizingCache == nil)
    {
        _sharedSizingCache = [[NSCache alloc] init];
    }
    return _sharedSizingCache;
}

+ (CGSize)actualSizeWithAnswerA:(NSAttributedString *)answerA
                        answerB:(NSAttributedString *)answerB
                    maximumSize:(CGSize)maximumSize
{
    CGSize maxSizeA = CGSizeMake(maximumSize.width/2, maximumSize.height);
    CGSize maxSizeB = CGSizeMake(maximumSize.width/2, maximumSize.height);
    
    CGRect boundingRectA = [answerA boundingRectWithSize:maxSizeA
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:[[NSStringDrawingContext alloc] init]];
    CGRect boundingRectB = [answerA boundingRectWithSize:maxSizeB
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:[[NSStringDrawingContext alloc] init]];
    
    return CGSizeMake(maximumSize.width,
                      MAX(kMinimumHeight, MAX(CGRectGetHeight(boundingRectA), CGRectGetHeight(boundingRectB))));
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 60.0f);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *unselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.answerAButton.backgroundColor = unselectedColor;
    self.answerBButton.backgroundColor = unselectedColor;
    
    self.answerAButton.titleLabel.numberOfLines = 0;
    self.answerBButton.titleLabel.numberOfLines = 0;
}

#pragma mark - Property Accessors

- (void)setAnswerA:(NSAttributedString *)answerA
{
    _answerA = [answerA copy];
    [self.answerAButton setAttributedTitle:_answerA
                                  forState:UIControlStateNormal];
}

- (void)setAnswerB:(NSString *)answerB
{
    _answerB = [answerB copy];
    [self.answerBButton setAttributedTitle:_answerB
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
