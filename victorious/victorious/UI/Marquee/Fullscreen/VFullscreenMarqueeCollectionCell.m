//
//  VFullscreenMarqueeCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeCollectionCell.h"

#import "VFullscreenMarqueeStreamItemCell.h"

#import "VStreamCollectionViewDataSource.h"
#import "VFullscreenMarqueeController.h"

#import "VStreamItem.h"

#import "VTimerManager.h"

#import "VStream.h"

#import "VAbstractMarqueeController.h"

@interface VFullscreenMarqueeCollectionCell() <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@end

@implementation VFullscreenMarqueeCollectionCell

@dynamic marquee;

- (void)awakeFromNib
{
    [self.marqueeCollectionView registerNib:[VFullscreenMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VFullscreenMarqueeStreamItemCell suggestedReuseIdentifier]];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - desiredCellSize

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
