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

static const CGFloat VCommentButtonContentRightInset = 3.0f; ///< Inset of comment content. This offset helps the comment count and image appear horizontally centered
static const CGFloat VButtonHeight = 36.0f; ///< Height of action buttons
static const CGFloat VCommentButtonWidth = 68.0f; ///< Width of comment button

static NSString * const VStreamCellActionViewGifIconKey = @"gifIcon"; ///< Key for "gif" icon
static NSString * const VStreamCellActionViewMemeIconKey = @"memeIcon"; ///< Key for "meme" icon
static NSString * const VStreamCellActionViewCommentIconKey = @"commentIcon"; ///< Key for "comment" icon

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

- (void)updateLayoutOfButtons
{
    //Remove widths of all POSSIBLY present buttons to have proper space between buttons even when not all 5 buttons are present
    CGFloat totalButtonWidths = VCommentButtonWidth + VButtonHeight * 4;
    
    CGFloat separatorSpace = ( CGRectGetWidth(self.bounds) - totalButtonWidths - VStreamCellActionViewActionButtonBuffer * 2 ) / 4;
    
    CGFloat yOrigin = (CGRectGetHeight(self.bounds) - VButtonHeight) / 2;
    
    for (NSUInteger i = 0; i < self.actionButtons.count; i++)
    {
        UIButton *button = self.actionButtons[i];
        CGRect frame = button.frame;
        if (i == 0)
        {
            frame.origin.x = VStreamCellActionViewActionButtonBuffer;
        }
        else
        {
            UIButton *lastButton = self.actionButtons[i - 1];
            frame.origin.x = CGRectGetMaxX(lastButton.frame) + separatorSpace;
        }
        
        //Fix frame of all buttons to be the
        frame.size.height = VButtonHeight;
        frame.origin.y = yOrigin;
        if ( ![button isEqual:self.commentsButton] )
        {
            frame.size.width = VButtonHeight;
        }
        button.frame = frame;
        
        //Setup the circles behind the images
        [button setClipsToBounds:YES];
        button.layer.cornerRadius = VButtonHeight / 2;
        
    }
}

- (void)updateCommentsCount:(NSNumber *)commentsCount
{
    [self.commentsButton setTitle:[self.largeNumberFormatter stringForInteger:[commentsCount integerValue]] forState:UIControlStateNormal];
}

- (void)addCommentsButton
{
    self.commentsButton = [self addButtonWithImageKey:VStreamCellActionViewCommentIconKey];
    [self.commentsButton addTarget:self action:@selector(commentsAction:) forControlEvents:UIControlEventTouchUpInside];
    self.commentsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.commentsButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, VCommentButtonContentRightInset);
    CGFloat yOrigin = ( CGRectGetHeight(self.commentsButton.frame) - VButtonHeight ) / 2.0f;
    [self.commentsButton setFrame:CGRectMake(self.commentsButton.frame.origin.x, yOrigin, VCommentButtonWidth, VButtonHeight)];

    [self refreshCommentsButtonAppearance];
}

- (void)commentsAction:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence fromView:self];
    }
}

- (void)addGifButton
{
    UIButton *button = [self addButtonWithImageKey:VStreamCellActionViewGifIconKey];
    [button addTarget:self action:@selector(gifAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gifAction:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRemixSequence:fromView:videoEdit:)])
    {
        [self.sequenceActionsDelegate willRemixSequence:self.sequence fromView:self videoEdit:VDefaultVideoEditGIF];
    }
}

- (void)addMemeButton
{
    UIButton *button = [self addButtonWithImageKey:VStreamCellActionViewMemeIconKey];
    [button addTarget:self action:@selector(memeAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)memeAction:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRemixSequence:fromView:videoEdit:)])
    {
        [self.sequenceActionsDelegate willRemixSequence:self.sequence fromView:self videoEdit:VDefaultVideoEditSnapshot];
    }
}

- (void)refreshCommentsButtonAppearance
{
    [self.commentsButton setBackgroundColor:[self commentButtonColor]];
    [[self.commentsButton titleLabel] setFont:[self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey]];
    
    //Override the default tint color to always have white text in the comment label
    [self.commentsButton setTintColor:[UIColor whiteColor]];
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

- (UIButton *)addButtonWithImage:(UIImage *)image
{
    UIButton *button = [super addButtonWithImage:image];
    button.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    return button;
}

+ (NSDictionary *)buttonImages
{
    static NSDictionary *buttonImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      buttonImages = @{
                                       VStreamCellActionViewShareIconKey : @"shareIcon-D",
                                       VStreamCellActionViewRepostIconKey : @"repostIcon-D",
                                       VStreamCellActionViewRepostSuccessIconKey : @"repostIcon-success-D",
                                       VStreamCellActionViewCommentIconKey : @"commentIcon-D",
                                       VStreamCellActionViewMemeIconKey : @"memeIcon-D",
                                       VStreamCellActionViewGifIconKey : @"gifIcon-D"
                                       };
                  });
    return buttonImages;
}

@end
