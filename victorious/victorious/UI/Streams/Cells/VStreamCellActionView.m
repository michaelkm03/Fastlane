//
//  VStreamCellActionView.m
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellActionView.h"

#import "VSequenceActionsDelegate.h"
#import "VSequence+Fetcher.h"

#import "VConstants.h"

#import "VDependencyManager.h"

static CGFloat const kGreyBackgroundColor       = 0.94509803921;
CGFloat const VStreamCellActionViewActionButtonBuffer = 15;
static CGFloat const kScaleActive               = 1.0f;
static CGFloat const kScaleScaledUp             = 1.4f;
static CGFloat const kRepostedDisabledAlpha     = 0.3f;

NSString * const VStreamCellActionViewShareIconKey = @"shareIcon";
NSString * const VStreamCellActionViewGifIconKey = @"gifIcon";
NSString * const VStreamCellActionViewMemeIconKey = @"memeIcon";
NSString * const VStreamCellActionViewRepostIconKey = @"repostIcon";
NSString * const VStreamCellActionViewRepostSuccessIconKey = @"repostSuccessIcon";

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
    
    [self updateLayoutOfButtons];
}

- (void)updateLayoutOfButtons
{
    CGFloat totalButtonWidths = 0.0f;
    for ( UIButton *button in self.actionButtons )
    {
        totalButtonWidths += CGRectGetWidth(button.bounds);
    }
    
    CGFloat separatorSpace = ( CGRectGetWidth(self.bounds) - totalButtonWidths ) / ( self.actionButtons.count );
    
    for (NSUInteger i = 0; i < self.actionButtons.count; i++)
    {
        UIButton *button = self.actionButtons[i];
        CGRect frame = button.frame;
        if (i == 0)
        {
            frame.origin.x = separatorSpace / 2;
        }
        else if (i == self.actionButtons.count-1)
        {
            frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(button.bounds) - ( separatorSpace / 2 );
        }
        else
        {
            UIButton *lastButton = self.actionButtons[i - 1];
            frame.origin.x = CGRectGetMaxX(lastButton.frame) + separatorSpace;
        }
        button.frame = frame;
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    UIColor *borderColor = [_dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    if ( borderColor != nil )
    {
        self.layer.borderColor = borderColor.CGColor;
    }
    
    UIColor *textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    if ( textColor != nil )
    {
        for ( UIButton *button in self.actionButtons )
        {
            [button setTintColor:textColor];
        }
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
    UIButton *button = [self addButtonWithImageKey:VStreamCellActionViewShareIconKey];
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareAction:(id)sender
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willShareSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willShareSequence:self.sequence fromView:self];
    }
}

- (void)addGifButton
{
    UIButton *button = [self addButtonWithImageKey:VStreamCellActionViewGifIconKey];
    [button addTarget:self action:@selector(gifAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gifAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
    
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
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
    
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willRemixSequence:fromView:videoEdit:)])
    {
        [self.sequenceActionsDelegate willRemixSequence:self.sequence fromView:self videoEdit:VDefaultVideoEditSnapshot];
    }
}

- (void)addRepostButton
{
    self.repostButton = [self addButtonWithImageKey:VStreamCellActionViewRepostIconKey];
    [self updateRepostButtonForRepostState];
}

- (void)updateRepostButtonForRepostState
{
    BOOL hasRespoted = [self.sequence.hasReposted boolValue];
    
    if (hasRespoted)
    {
        NSString *imageName = [[[self class] buttonImages] objectForKey:VStreamCellActionViewRepostSuccessIconKey];
        UIImage *selectedImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.repostButton setImage:selectedImage forState:UIControlStateNormal];
    }
    else
    {
        [self.repostButton addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.repostButton.alpha = hasRespoted ? kRepostedDisabledAlpha : 1.0f;
}

- (void)repostAction:(id)sender
{
    if ( ![self.sequenceActionsDelegate respondsToSelector:@selector(willRepostSequence:fromView:completion:)] )
    {
        return;
    }

    self.repostButton.enabled = NO;
    [self.sequenceActionsDelegate willRepostSequence:self.sequence
                                            fromView:self
                                          completion:^(BOOL didSucceed)
     {
         self.repostButton.enabled = YES;
         if (!didSucceed)
         {
             [self updateRepostButtonForRepostState];
             return;
         }
         
         self.isAnimatingButton = YES;
         
         [UIView animateWithDuration:0.15f
                               delay:0.0f
              usingSpringWithDamping:1.0f
               initialSpringVelocity:0.8f
                             options:kNilOptions
                          animations:^
          {
              [self updateRepostButtonForRepostState];
              self.repostButton.transform = CGAffineTransformMakeScale( kScaleScaledUp, kScaleScaledUp );
              self.repostButton.alpha = kRepostedDisabledAlpha;
          }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.5f
                                    delay:0.0f
                   usingSpringWithDamping:0.8f
                    initialSpringVelocity:0.9f
                                  options:kNilOptions
                               animations:^
               {
                   self.repostButton.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
               }
                               completion:^(BOOL finished)
               {
                   self.isAnimatingButton = NO;
               }];
          }];
     }];
}

- (UIButton *)addButtonWithImageKey:(NSString *)imageKey
{
    NSString *imageName = [[[self class] buttonImages] objectForKey:imageKey];
    return [self addButtonWithImage:[UIImage imageNamed:imageName]];
}

- (UIButton *)addButtonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    CGFloat buttonSide = CGRectGetHeight(self.bounds);
    button.frame = CGRectMake(0, 0, buttonSide, buttonSide);
    button.tintColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    [self addSubview:button];
    [self.actionButtons addObject:button];
    return button;
}

//Dictionary of images to use. This is a shared instance just to be easily subclassable (if not you have to know where it was instantiated in the superclass and overwrite it afterwards)
+ (NSDictionary *)buttonImages
{
    static NSDictionary *buttonImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      buttonImages = @{
                                       VStreamCellActionViewShareIconKey : @"C_shareIcon",
                                       VStreamCellActionViewGifIconKey : @"C_gifIcon",
                                       VStreamCellActionViewMemeIconKey : @"C_memeIcon",
                                       VStreamCellActionViewRepostIconKey : @"C_repostIcon",
                                       VStreamCellActionViewRepostSuccessIconKey : @"C_repostIcon-success"
                                       };
                  });
    return buttonImages;
}

@end
