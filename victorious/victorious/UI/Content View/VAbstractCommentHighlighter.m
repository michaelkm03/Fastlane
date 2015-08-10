//
//  VCommentHighlighter.m
//  victorious
//
//  Created by Patrick Lynch on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCommentHighlighter.h"
#import "VTimerManager.h"
#import "VThemeManager.h"
#import "UIColor+VBrightness.h"

static NSString * const kTargetIndexPath = @"com.getvictorious.targetIndexPathKey";
static NSString * const kCompletionCallback = @"com.getvictorious.completionCallbackKey";

@interface VAbstractCommentHighlighter()

@property (nonatomic, strong) VTimerManager *cellHighlightAnimationTimer;
@property (nonatomic, assign, readwrite) BOOL isAnimatingCellHighlight;

@end

@implementation VAbstractCommentHighlighter

- (void)dealloc
{
    [self stopAnimations];
}

- (void)stopAnimations
{
    self.isAnimatingCellHighlight = NO;
    [self.cellHighlightAnimationTimer invalidate];
}

- (void)scrollToAndHighlightIndexPath:(NSIndexPath *)indexPath delay:(NSTimeInterval)delay completion:(void(^)())completion
{
    self.isAnimatingCellHighlight = YES;
    
    __weak VAbstractCommentHighlighter *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       __strong VAbstractCommentHighlighter *strongSelf = weakSelf;
                       if ( strongSelf == nil )
                       {
                           return;
                       }
                       
                       // Start the timer to wait for the cell in the collectionView to be created as the scrolling animation plays
                       if ([strongSelf numberOfSections] >= indexPath.section)
                       {
                           NSDictionary *userInfo = @{ kTargetIndexPath : indexPath, kCompletionCallback : (completion ?: ^{}) };
                           strongSelf.cellHighlightAnimationTimer = [VTimerManager scheduledTimerManagerWithTimeInterval:1.0/30.0
                                                                                                                  target:strongSelf
                                                                                                                selector:@selector(showHighlightAnimation:)
                                                                                                                userInfo:userInfo
                                                                                                                 repeats:YES];
                           
                           [strongSelf scrollToIndexPath:indexPath];
                       }
                   });
    
}

- (void)showHighlightAnimation:(NSTimer *)timer
{
    if ( !self.isAnimatingCellHighlight )
    {
        [self stopAnimations];
        return;
    }
    
    NSIndexPath *indexPath = (NSIndexPath *)timer.userInfo[ kTargetIndexPath ];
    void (^completion)() = timer.userInfo[ kCompletionCallback ];
    
    UIView *view = [self viewToAnimateForIndexPath:indexPath];
    if (view == nil )
    {
        return;
    }
    
    // Once we've got the reference to the cell, we can cancel the timer and proceed with the animation
    [self.cellHighlightAnimationTimer invalidate];
    
    UIColor *startColor = view.backgroundColor;
    
    // Set the cell's background color to a lightened version of the themed color
    UIColor *color = [[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] v_colorLightenedBy:0.9f];
    view.backgroundColor = color;
    
    // Animate it back to white
    [UIView animateKeyframesWithDuration:0.7f delay:0.8f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        view.backgroundColor = startColor;
    }
                              completion:^(BOOL finished)
     {
         if ( self.isAnimatingCellHighlight )
         {
             self.isAnimatingCellHighlight = NO;
             if ( completion != nil )
             {
                 completion();
             }
         }
     }];
}

#pragma mark - Required overrides

- (NSInteger)numberOfSections
{
    NSAssert(false, @"Subclasses of VAbstractCommentHighlighter must override numberOfSections");
    return 0;
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(false, @"Subclasses of VAbstractCommentHighlighter must override scrollToIndexPath:");
}

- (UIView *)viewToAnimateForIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(false, @"Subclasses of VAbstractCommentHighlighter must override viewToAnimateForIndexPath:");
    return nil;
}

@end
