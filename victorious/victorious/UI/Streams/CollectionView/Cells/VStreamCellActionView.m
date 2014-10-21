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

static CGFloat const kGreyBackgroundColor = 0.94509803921;
static CGFloat const kVActionButtonBuffer = 15;

@interface VStreamCellActionView()

@property (nonatomic, strong) NSMutableArray *actionButtons;

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
    UIButton *button = [self addButtonWithImage:[UIImage imageNamed:@"repostIcon-C"]];
    [button addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)repostAction:(id)sender
{
    BOOL canRepost = YES;
    if ([self.delegate respondsToSelector:@selector(willRepostSequence:fromView:)])
    {
        canRepost = [self.delegate willRepostSequence:self.sequence fromView:self];
    }
    
    ((UIButton *)sender).enabled = canRepost;
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
    [self setNeedsLayout];
    return button;
}

@end
