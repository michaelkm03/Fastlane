//
//  VCommentHighlighter.m
//  victorious
//
//  Created by Patrick Lynch on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommentHighlighter.h"
#import "VContentCommentsCell.h"
#import "VThemeManager.h"
#import "UIColor+Brightness.h"

static NSString * const kTargetIndexPath = @"com.getvictorious.targetIndexPathKey";
static NSString * const kCompletionCallback = @"com.getvictorious.completionCallbackKey";

@interface VCommentHighlighter()

@property (nonatomic, strong) NSTimer *cellHighlightAnimationTimer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign, readwrite) BOOL isAnimatingCellHighlight;

@end

@implementation VCommentHighlighter

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        _collectionView = collectionView;
    }
    return self;
}

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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       // Start the timer to wait for the cell in the collectionView to be created as the scrolling animation plays
                       NSDictionary *userInfo = @{ kTargetIndexPath : indexPath, kCompletionCallback : (completion ?: ^{}) };
                       self.cellHighlightAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self
                                                                                         selector:@selector(showHighlightAnimation:)
                                                                                         userInfo:userInfo
                                                                                          repeats:YES];
                       
                       [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
    
    VContentCommentsCell *cell = (VContentCommentsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ( cell == nil || ![cell isKindOfClass:[VContentCommentsCell class]] )
    {
        return;
    }
    
    // Once we've got the reference to the cell, we can cancel the timer and proceed with the animation
    [self.cellHighlightAnimationTimer invalidate];
    
    // Set the cell's background color to a lightened version of the themed color
    UIColor *color = [[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor] v_colorLightenedBy:0.9f];
    cell.backgroundColor = color;
    
    // Animate it back to white
    [UIView animateKeyframesWithDuration:0.7f delay:0.8f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        cell.backgroundColor = [UIColor whiteColor];
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

@end
