//
//  VBaseMarqueeCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeCellFactory.h"
#import "VSequence.h"
#import "VFullscreenMarqueeCollectionCell.h"
#import "VFullscreenMarqueeStreamItemCell.h"
#import "VFullscreenMarqueeController.h"
#import "NSString+VParseHelp.h"
#import "VObjectManager.h"
#import "VStream+Fetcher.h"
#import "VDependencyManager.h"

@interface VFullscreenMarqueeCellFactory ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VFullscreenMarqueeController *marquee;
@property (nonatomic, strong) VFullscreenMarqueeCollectionCell *marqueeCollectionCell;

@end

@implementation VFullscreenMarqueeCellFactory

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
    [collectionView registerNib:[VFullscreenMarqueeCollectionCell nibForCell] forCellWithReuseIdentifier:[VFullscreenMarqueeCollectionCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    if ( self.marqueeCollectionCell == nil )
    {
        VFullscreenMarqueeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VFullscreenMarqueeCollectionCell suggestedReuseIdentifier]
                                                                               forIndexPath:indexPath];
        cell.dependencyManager = self.dependencyManager;
        cell.marquee = self.marquee;
        CGSize desiredSize = [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
        cell.bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
        cell.hideMarqueePosterImage = YES;
        self.marqueeCollectionCell = cell;
    }

    [self.marquee enableTimer];
    return self.marqueeCollectionCell;
}

- (VFullscreenMarqueeController *)marquee
{
    if (!_marquee)
    {
        VStream *marquee = [VStream streamForPath:[[self.dependencyManager stringForKey:kMarqueeURLKey] v_pathComponent] inContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        _marquee = [[VFullscreenMarqueeController alloc] initWithStream:marquee];
        
        //The top of the template C hack
        _marquee.hideMarqueePosterImage = YES;
        _marquee.dependencyManager = self.dependencyManager;
        _marquee.delegate = self.delegate;
    }
    return _marquee;
}

- (void)enableTimer
{
    [self.marquee enableTimer];
}

- (void)setDelegate:(id<VFullscreenMarqueeControllerDelegate>)delegate
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
    return [VFullscreenMarqueeCollectionCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
