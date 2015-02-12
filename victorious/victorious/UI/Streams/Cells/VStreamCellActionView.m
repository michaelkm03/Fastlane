//
//  VStreamCellActionView.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellActionView.h"

#import "VSequence+Fetcher.h"
#import "VThemeManager.h"

#import "VConstants.h"

static CGFloat const kGreyBackgroundColor = 0.94509803921;
static CGFloat const kVActionButtonBuffer = 15;
static CGFloat const kVScaleActive       = 1.0f;
static CGFloat const kVScaleScaledUp     = 1.4f;

@interface VStreamCellActionView()

@property (nonatomic, strong) NSMutableArray *actionButtons;

@property (nonatomic, weak) UIButton *repostButton;

@property (nonatomic, assign) BOOL isAnimatingButton;

@end

@implementation VStreamCellActionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithWhite:kGreyBackgroundColor alpha:1].CGColor;
    self.actionButtons = [[NSMutableArray alloc] init];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( self.isAnimatingButton )
    {
        return;
    }

    for (NSUInteger i = 0; i < self.actionButtons.count; i++)
    {
        UIButton *button = self.actionButtons[i];
        CGRect frame = button.frame;
        if (i == 0)
        {
            frame.origin.x = kVActionButtonBuffer;
        }
        else if (i == self.actionButtons.count-1)
        {
            frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(button.bounds) - kVActionButtonBuffer;
        }
        else
        {
            //Count up all the available space (minus buttons and the buffers)
            CGFloat leftOvers = CGRectGetWidth(self.bounds) - CGRectGetWidth(button.bounds) * self.actionButtons.count - kVActionButtonBuffer * 2;
            //Left overs per button. 
            CGFloat leftoversPerButton = leftOvers / (self.actionButtons.count - 1);
            
            frame.origin.x = kVActionButtonBuffer + (leftoversPerButton + CGRectGetWidth(button.bounds)) * i;
        }
        button.frame = frame;
    }
}

- (void)clearButtons
{
    for (UIButton *button in self.actionButtons)
    {
        [button removeFromSuperview];
    }
    [self.actionButtons removeAllObjects];
}

- (void)addShareButton
{
    UIButton *button = [self addButtonWithImage:[UIImage imageNamed:@"shareIcon-C"]];
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willShareSequence:fromView:)])
    {
        [self.delegate willShareSequence:self.sequence fromView:self];
    }
}

- (void)addRemixButton
{
    UIButton *button = [self addButtonWithImage:[UIImage imageNamed:@"remixIcon-C"]];
    [button addTarget:self action:@selector(remixAction:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL hasRespoted = NO;
    if ( [self.delegate respondsToSelector:@selector(hasRepostedSequence:)] )
    {
        hasRespoted = [self.delegate hasRepostedSequence:self.sequence];
    }
    
    self.repostButton.alpha = hasRespoted ? 0.5f : 1.0f;
    NSString *imageName = hasRespoted ? @"repostIcon-success-C" : @"repostIcon-C";
    [self.repostButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)remixAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willRemixSequence:fromView:)])
    {
        [self.delegate willRemixSequence:self.sequence fromView:self];
    }
}

- (void)addRepostButton
{
    self.repostButton = [self addButtonWithImage:[UIImage imageNamed:@"repostIcon-C"]];
    [self.repostButton addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)repostAction:(id)sender
{
    if ( ![self.delegate respondsToSelector:@selector(willRepostSequence:fromView:completion:)] ||
         ![self.delegate respondsToSelector:@selector(hasRepostedSequence:)] )
    {
        return;
    }
    
    if ( ![self.delegate hasRepostedSequence:self.sequence] )
    {
        return;
    }
    
    self.repostButton.alpha = 0.5f;
    
    [self.delegate willRepostSequence:self.sequence fromView:self completion:^(BOOL didSucceed)
     {
         self.isAnimatingButton = YES;
         [self.repostButton setImage:[UIImage imageNamed:@"repostIcon-success-C"] forState:UIControlStateNormal];
         
         [UIView animateWithDuration:0.15f
                               delay:0.0f
              usingSpringWithDamping:1.0f
               initialSpringVelocity:0.8f
                             options:kNilOptions animations:^
          {
              self.repostButton.transform = CGAffineTransformMakeScale( kVScaleScaledUp, kVScaleScaledUp );
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.5f
                                    delay:0.0f
                   usingSpringWithDamping:0.8f
                    initialSpringVelocity:0.9f
                                  options:kNilOptions animations:^
               {
                   self.repostButton.transform = CGAffineTransformMakeScale( kVScaleActive, kVScaleActive );
               }
                               completion:^(BOOL finished)
               {
                   self.isAnimatingButton = NO;
               }];
          }];
     }];
}

- (void)addFlagButton
{
    UIButton *button = [self addButtonWithImage:[UIImage imageNamed:@"overflowBtn-C"]];
    [button addTarget:self action:@selector(flagAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)flagAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willFlagSequence:fromView:)])
    {
        [self.delegate willFlagSequence:self.sequence fromView:self];
    }
}

- (UIButton *)addButtonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    [self addSubview:button];
    [self.actionButtons addObject:button];
    return button;
}

@end
