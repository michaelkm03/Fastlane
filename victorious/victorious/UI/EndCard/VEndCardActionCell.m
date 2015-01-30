//
//  VEndCardActionCell.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardActionCell.h"

static const CGFloat kScaleInactive     = 0.8f;
static const CGFloat kScaleMax          = 1.2f;
static const CGFloat kScaleActive       = 1.0f;

@interface VEndCardActionCell ()

@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;

@end

@implementation VEndCardActionCell

+ (NSString *)cellIdentifier
{
    return NSStringFromClass( [self class] );
}

+ (CGSize)minimumSize
{
    return CGSizeMake( 68.0f, 95.0f );
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self resetAnimationState];
}

- (void)setTitle:(NSString *)title
{
    [self.actionLabel setText:title];
}

- (void)setImage:(UIImage *)image
{
    self.actionImageView.image = image;
}

- (void)setTitleAlpha:(CGFloat)alpha
{
    self.actionLabel.alpha = alpha;
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = self.selected;
    
    [super setSelected:selected];
    
    if ( !wasSelected && selected )
    {
        [self playSelectionAnimation];
    }
}

- (void)playSelectionAnimation
{
    [UIView animateWithDuration:0.25f
                          delay:0.0f
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.8
                        options:kNilOptions animations:^
     {
         self.alpha = 1.0f;
         self.transform = CGAffineTransformMakeScale( kScaleMax, kScaleMax );
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f
                               delay:0.0f
              usingSpringWithDamping:0.8
               initialSpringVelocity:0.0
                             options:kNilOptions animations:^
          {
              self.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
          }
                          completion:nil];
     }];
}

- (void)playDisableAnimation
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:kNilOptions animations:^
     {
         self.alpha = 0.25f;
         self.transform = CGAffineTransformMakeScale( kScaleInactive, kScaleInactive );
     }
                     completion:nil];
}

- (void)resetAnimationState
{
    self.alpha = 1.0f;
    self.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
}

- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    CGFloat scale = 0.8f;
    self.alpha = 0.0f;
    self.transform = CGAffineTransformMakeScale( scale, scale );
    
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.8
                        options:kNilOptions animations:^
     {
         CGFloat scale = 1.2f;
         self.alpha = 1.0f;
         self.transform = CGAffineTransformMakeScale( scale, scale );
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f
                               delay:0.0f
              usingSpringWithDamping:0.8
               initialSpringVelocity:0.0
                             options:kNilOptions animations:^
          {
              self.alpha = 1.0f;
              self.transform = CGAffineTransformMakeScale( kScaleActive, kScaleActive );
          }
                          completion:nil];
     }];
}

- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.8
                        options:kNilOptions animations:^
     {
         self.alpha = 0.0f;
         self.transform = CGAffineTransformMakeScale( kScaleInactive, kScaleInactive );
     }
                     completion:completion];
}

@end
