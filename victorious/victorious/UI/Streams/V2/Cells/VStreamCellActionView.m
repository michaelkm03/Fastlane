//
//  VStreamCellActionView.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellActionView.h"

#import "VSequence+Fetcher.h"

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
            CGFloat leftOvers = CGRectGetWidth(self.bounds) - CGRectGetWidth(button.bounds) * (self.actionButtons.count - 1) -kVActionButtonBuffer * 2;
            //Left overs per button. 
            CGFloat leftoversPerButton = leftOvers / self.actionButtons.count;
            
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
    [self addButtonWithImage:[UIImage imageNamed:@"shareIcon-C"]
                      action:@selector(willShareSequence:fromView:)];
}

- (void)addRemixButton
{
    [self addButtonWithImage:[UIImage imageNamed:@"remixIcon-C"]
                      action:@selector(willRemixSequence:fromView:)];
}

- (void)addRepostButton
{
    [self addButtonWithImage:[UIImage imageNamed:@"repostIcon-C"]
                       action:@selector(willRepostSequence:fromView:)];
}

- (void)addFlagButton
{
    [self addButtonWithImage:[UIImage imageNamed:@"overflowBtn-C"]
                      action:@selector(willFlagSequence:fromView:)];
}

- (void)addButtonWithImage:(UIImage *)image action:(SEL)action
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    if ([self.delegate respondsToSelector:action])
    {
        [button addTarget:self.delegate action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    [self.actionButtons addObject:button];
    [self setNeedsLayout];
}

@end
