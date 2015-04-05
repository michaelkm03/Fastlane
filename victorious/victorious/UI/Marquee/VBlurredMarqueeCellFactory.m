//
//  VBlurredMarqueeCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeCellFactory.h"
#import "VBlurredMarqueeCollectionViewCell.h"
#import "VBlurredMarqueeController.h"
#import "VBlurredMarqueeStreamItemCell.h"
#import "VDependencyManager.h"
#import "NSString+VParseHelp.h"
#import "VObjectManager.h"
#import "VStream+Fetcher.h"

@interface VBlurredMarqueeCellFactory ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VBlurredMarqueeController *marquee;
@property (nonatomic, strong) VBlurredMarqueeCollectionViewCell *marqueeCollectionCell;

@end

@implementation VBlurredMarqueeCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)dealloc
{
    self.marquee = nil;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VBlurredMarqueeCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    if ( self.marqueeCollectionCell == nil )
    {
        VBlurredMarqueeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]
                                                                                           forIndexPath:indexPath];
        cell.dependencyManager = self.dependencyManager;
        cell.marquee = self.marquee;
        CGSize desiredSize = [VBlurredMarqueeCollectionViewCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
        cell.bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
        self.marqueeCollectionCell = cell;
    }
    
    [self.marquee enableTimer];
    return self.marqueeCollectionCell;
}

- (VBlurredMarqueeController *)marquee
{
    if (!_marquee)
    {
        VStream *marqueeStream = [VStream streamForPath:[[self.dependencyManager stringForKey:kMarqueeURLKey] v_pathComponent] inContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        _marquee = [[VBlurredMarqueeController alloc] initWithStream:marqueeStream];
        
        _marquee.dependencyManager = self.dependencyManager;
        _marquee.delegate = self.delegate;
    }
    return _marquee;
}

- (void)enableTimer
{
    [self.marquee enableTimer];
}

- (void)setDelegate:(id<VMarqueeControllerDelegate>)delegate
{
    _delegate = delegate;
    self.marquee.delegate = delegate;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.marqueeCollectionCell.dependencyManager = dependencyManager;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VBlurredMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
