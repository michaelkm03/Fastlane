//
//  VAbstractMarqueeCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeCollectionViewCell.h"
#import "VAbstractMarqueeStreamItemCell.h"
#import "VStreamCollectionViewDataSource.h"
#import "VTimerManager.h"
#import "VAbstractMarqueeController.h"

@interface VAbstractMarqueeCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UICollectionView *marqueeCollectionView;

@end

@implementation VAbstractMarqueeCollectionViewCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"Subclasses must override desiredSizeWithCollectionViewBounds: in VAbstractMarqueeCollectionViewCell");
    return CGSizeZero;
}

- (void)setMarquee:(VAbstractMarqueeController *)marquee
{
    _marquee = marquee;
    marquee.collectionView = self.marqueeCollectionView;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.marquee disableTimer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.marquee disableTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.marquee enableTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.marquee enableTimer];
}

#pragma mark - VFocusable

@synthesize focusType = _focusType;

- (void)setFocusType:(VFocusType)focusType
{
    if (_focusType == focusType)
    {
        return;
    }
    
    _focusType = focusType;
    switch (focusType)
    {
        case VFocusTypeNone:
        case VFocusTypeTransition:
            [self.marquee disableTimer];
            [self.marquee endFocusOnAllCells];
            break;
        case VFocusTypeStream:
        case VFocusTypeDetail:
            [self.marquee enableTimer];
            [self.marquee updateFocus];
            [self.marquee updateCellVisibilityTracking];
            break;
    }
}

- (CGRect)contentArea
{
    return self.frame;
}

#pragma mark - Parallax Scrolling

- (CGFloat)parallaxRatio
{
    return 0.5f;
}

@end
