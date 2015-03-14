//
//  VStreamCellActionViewD.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellActionViewD.h"

@interface VStreamCellActionViewD ()

@property (nonatomic, strong) UIButton *commentsButton;

@end

@implementation VStreamCellActionViewD

- (void)updateCommentsCount:(NSNumber *)commentsCount
{
    [self.commentsButton setTitle:[commentsCount stringValue] forState:UIControlStateNormal];
}

- (void)addCommentsButton
{
    self.commentsButton = [self addButtonWithImage:[UIImage imageNamed:@"remixIcon-C"]];
    [self.commentsButton addTarget:self action:@selector(commentsAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)commentsAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
    
    if ([self.delegate respondsToSelector:@selector(willRemixSequence:fromView:)])
    {
        [self.delegate willRemixSequence:self.sequence fromView:self];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor
{
    _buttonBackgroundColor = buttonBackgroundColor;
    
    //Update background color of all the buttons
    for (UIButton *button in self.actionButtons)
    {
        [button setClipsToBounds:YES];
        button.layer.cornerRadius = CGRectGetHeight(button.bounds) / 2.0f;
        [button setBackgroundColor:buttonBackgroundColor];
    }
}

- (UIButton *)addButtonWithImage:(UIImage *)image
{
    UIButton *button = [super addButtonWithImage:image];
    button.backgroundColor = self.buttonBackgroundColor;
    return button;
}

@end
