//
//  VBaseMarqueeCollectionViewCell.m
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

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

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
    marquee.collectionView = self.collectionView;
    
    [self.marquee refreshWithSuccess:^(void)
     {
         [self.marquee enableTimer];
         [self updatedFromRefresh];
         
     } failure:nil];
}

- (void)updatedFromRefresh
{
    //Point for subclasses to override if they want to do anything after refresh
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.marquee.dependencyManager = dependencyManager;
}

- (VStreamItem *)currentItem
{
    return self.marquee.currentStreamItem;
}

- (UIImageView *)currentPreviewImageView
{
    NSIndexPath *path = [self.marquee.streamDataSource indexPathForItem:[self currentItem]];
    VAbstractMarqueeStreamItemCell *cell = (VAbstractMarqueeStreamItemCell *)[self.collectionView cellForItemAtIndexPath:path];
    return cell.previewImageView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.marquee.autoScrollTimerManager invalidate];
}

- (void)restartAutoScroll
{
    [self.marquee enableTimer];
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

@end
