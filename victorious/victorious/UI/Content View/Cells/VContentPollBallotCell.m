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

static CGFloat const kMinimumHeight = 60.0f;
static UIEdgeInsets const kAnswerInsets = { 10, 0, 10, 0};
static CGFloat const kOrSizeInset = 40.0f;

@interface VContentPollBallotCell ()

@property (weak, nonatomic) IBOutlet UIButton *answerAButton;
@property (weak, nonatomic) IBOutlet UIButton *answerBButton;
@property (weak, nonatomic) IBOutlet UILabel *aLabel;
@property (weak, nonatomic) IBOutlet UILabel *bLabel;

@end

@implementation VContentPollBallotCell

+ (NSMutableDictionary *)sharedSizingCache
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary *sizingCache;
    dispatch_once(&onceToken, ^
    {
        sizingCache = [[NSMutableDictionary alloc] init];
    });
    
    return sizingCache;
}

+ (void)clearSizingCache
{
    [[self sharedSizingCache] removeAllObjects];
}

+ (CGSize)actualSizeWithAnswerA:(NSAttributedString *)answerA
                        answerB:(NSAttributedString *)answerB
                    maximumSize:(CGSize)maximumSize
{
    NSString *keyForParameters = [NSString stringWithFormat:@"%@,%@,%@", answerA.string, answerB.string, NSStringFromCGSize(maximumSize)];
    
    NSValue *cachedValue = [[self sharedSizingCache] objectForKey:keyForParameters];
    if (cachedValue != nil)
    {
        return [cachedValue CGSizeValue];
    }
    
    CGSize maxSizeA = CGSizeMake(maximumSize.width/2 - kOrSizeInset, maximumSize.height);
    CGSize maxSizeB = CGSizeMake(maximumSize.width/2 - kOrSizeInset, maximumSize.height);

    CGRect boundingRectA = [answerA boundingRectWithSize:maxSizeA
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:[[NSStringDrawingContext alloc] init]];
    CGRect boundingRectB = [answerB boundingRectWithSize:maxSizeB
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:[[NSStringDrawingContext alloc] init]];
    
    CGFloat maxBoundingHeight = MAX(CGRectGetHeight(boundingRectA), CGRectGetHeight(boundingRectB));
    maxBoundingHeight = maxBoundingHeight + kAnswerInsets.top + kAnswerInsets.bottom;
    
    CGSize totalSize = CGSizeMake(maximumSize.width,
                                  MAX(kMinimumHeight, maxBoundingHeight));
    
    [[self sharedSizingCache] setObject:[NSValue valueWithCGSize:totalSize]
                                 forKey:keyForParameters];
    
    return totalSize;
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 60.0f);
}

#pragma mark - NSObject

- (void)dealloc
{
    [[self class] clearSizingCache];
}

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
    self.aLabel.attributedText = _answerA;
}

- (void)setAnswerB:(NSString *)answerB
{
    _answerB = [answerB copy];
    self.bLabel.attributedText = _answerB;
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

- (IBAction)touchDownA:(id)sender
{
    [self setHighlighted:YES onLabel:self.aLabel];
}

- (IBAction)touchUpA:(id)sender
{
    [self setHighlighted:NO onLabel:self.aLabel];
}

- (IBAction)selectedAnswerB:(id)sender
{
    if (self.answerBSelectionHandler)
    {
        self.answerBSelectionHandler();
    }
}

- (IBAction)touchDownB:(id)sender
{
    [self setHighlighted:YES onLabel:self.bLabel];
}

- (IBAction)touchUpB:(id)sender
{
    [self setHighlighted:NO onLabel:self.bLabel];
}

- (void)setHighlighted:(BOOL)highlighted
               onLabel:(UILabel *)label
{
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         label.alpha = highlighted ? 0.5f : 1.0f;
     }
                     completion:nil];
}

@end
