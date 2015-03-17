//
//  VStreamCellActionViewD.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCellActionView.h"
#import "VDependencyManager.h"
#import "VLargeNumberFormatter.h"
#import "VSequenceActionsDelegate.h"

static const CGFloat VCommentButtonContentInset = 6.0f;
static const CGFloat VCommentButtonHeight = 32.0f;

@interface VSleekStreamCellActionView ()

@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, assign) CGFloat commentButtonYOrigin;
@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VSleekStreamCellActionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
}

- (void)updateCommentsCount:(NSNumber *)commentsCount
{
    [self.commentsButton setTitle:[self.largeNumberFormatter stringForInteger:[commentsCount integerValue]] forState:UIControlStateNormal];
    [self.commentsButton layoutIfNeeded];
    CGRect newFrame = self.commentsButton.frame;
    newFrame.size.width = [self.commentsButton sizeThatFits:self.commentsButton.bounds.size].width;
    newFrame.size.width += self.commentsButton.layer.cornerRadius * 1.5f; //Padding to keep text and icon out of rounded corner mask
    newFrame.origin.y = self.commentButtonYOrigin;
    [self.commentsButton setFrame:newFrame];
    [self layoutSubviews];
}

- (void)addCommentsButton
{
    self.commentsButton = [self addButtonWithImage:[UIImage imageNamed:@"Comment"]];
    [self.commentsButton addTarget:self action:@selector(commentsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsButton setClipsToBounds:YES];
    self.commentsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.commentsButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, VCommentButtonContentInset / 2.0f);
    self.commentsButton.imageEdgeInsets = UIEdgeInsetsMake(VCommentButtonContentInset, -VCommentButtonContentInset / 2.0f, VCommentButtonContentInset, VCommentButtonContentInset / 2.0f);
    CGRect revisedFrame = self.commentsButton.frame;
    self.commentButtonYOrigin = ( CGRectGetHeight(revisedFrame) - VCommentButtonHeight ) / 2.0f;
    revisedFrame.size.height = VCommentButtonHeight;
    [self.commentsButton setFrame:revisedFrame];
    self.commentsButton.layer.cornerRadius = CGRectGetHeight(self.commentsButton.bounds) / 2.0f;

    [self refreshCommentsButtonAppearance];
}

- (void)refreshCommentsButtonAppearance
{
    [self.commentsButton setBackgroundColor:[self commentButtonColor]];
    [[self.commentsButton titleLabel] setFont:[self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey]];
    
    //Override the default tint color to always have white text in the comment label
    [self.commentsButton setTintColor:[UIColor whiteColor]];
}

- (void)commentsAction:(id)sender
{    
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence fromView:self];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    [self refreshCommentsButtonAppearance];
}

- (UIColor *)commentButtonColor
{
    return [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

@end
