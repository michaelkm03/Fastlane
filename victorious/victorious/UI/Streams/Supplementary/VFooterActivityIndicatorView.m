//
//  VFooterActivityIndicatorView.m
//  victorious
//
//  Created by Patrick Lynch on 2/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFooterActivityIndicatorView.h"

static const CGFloat kActivityIndicatorScale = 0.8f;
static const CGFloat kSupplementaryViewHeight = 60.0f;

@interface VFooterActivityIndicatorView()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation VFooterActivityIndicatorView

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass( [self class] );
}

+ (UINib *)nibForSupplementaryView
{
    return [UINib nibWithNibName:NSStringFromClass( [self class] ) bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)collectionViewBounds
{
    return CGSizeMake( CGRectGetWidth(collectionViewBounds), kSupplementaryViewHeight );
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.activityIndicator.transform = CGAffineTransformMakeScale( 0, 0 );
}

- (void)setActivityIndicatorVisible:(BOOL)visible animated:(BOOL)animated
{
    void (^animations)() = ^
    {
        // Set the final target state of the animation
        CGFloat scale = visible ? kActivityIndicatorScale : 0.0f;
        self.activityIndicator.transform = CGAffineTransformMakeRotation( -M_PI * 5.0f );
        self.activityIndicator.transform = CGAffineTransformMakeScale( scale, scale );
    };
    
    if ( animated )
    {
        // Set initial state of animation
        CGFloat scale = visible ? 0.0f : kActivityIndicatorScale;
        self.activityIndicator.transform = CGAffineTransformMakeRotation( 0 );
        self.activityIndicator.transform = CGAffineTransformMakeScale( scale, scale );
        
        [UIView animateWithDuration:0.5f
                              delay:0.25f
             usingSpringWithDamping:0.9f
              initialSpringVelocity:0.8f
                            options:kNilOptions
                         animations:animations
                         completion:nil];
    }
    else
    {
        animations();
    }
}

@end
