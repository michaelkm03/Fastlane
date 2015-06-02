//
//  VNoContentCollectionViewCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNoContentCollectionViewCellFactory.h"
#import "VNoContentCollectionViewCell.h"

@interface VNoContentCollectionViewCellFactory ()

@property (nonatomic, strong) NSArray *acceptableClasses;

@end

@implementation VNoContentCollectionViewCellFactory

- (instancetype)initWithAcceptableContentClasses:(NSArray *)acceptableClasses
{
    self = [super init];
    if ( self != nil )
    {
        NSParameterAssert(acceptableClasses.count > 0);
        _acceptableClasses = acceptableClasses;
    }
    return self;
}

- (void)registerNoContentCellWithCollectionView:(UICollectionView *)collectionView
{
    NSParameterAssert( [collectionView isKindOfClass:[UICollectionView class]] );
    [collectionView registerClass:[VNoContentCollectionViewCell class] forCellWithReuseIdentifier:[VNoContentCollectionViewCell suggestedReuseIdentifier]];
}

- (CGSize)cellSizeForCollectionViewBounds:(CGRect)bounds
{
    return [VNoContentCollectionViewCell desiredSizeWithCollectionViewBounds:bounds];
}

- (UICollectionViewCell *)noContentCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert( collectionView != nil );
    NSParameterAssert( indexPath != nil );
    return [collectionView dequeueReusableCellWithReuseIdentifier:[VNoContentCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
}

- (BOOL)shouldDisplayNoContentCellForContentClass:(Class)contentClass
{
    return ![self.acceptableClasses containsObject:contentClass];
}

+ (BOOL)isNoContentCell:(UICollectionViewCell *)collectionViewCell
{
    return [collectionViewCell isKindOfClass:[VNoContentCollectionViewCell class]];
}

@end
