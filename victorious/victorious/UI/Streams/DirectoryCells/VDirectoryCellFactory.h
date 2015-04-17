//
//  VDirectoryCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VStreamItem, VStream, VDependencyManager;

@protocol VDirectoryCellFactory <NSObject, VHasManagedDependencies>

@required

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds andStreamItem:(VStreamItem *)streamItem;

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem;

- (CGFloat)minimumInterItemSpacing;

- (CGFloat)minimumLineSpacing;

- (UIEdgeInsets)sectionEdgeInsets;

@optional

- (void)prepareCell:(UICollectionViewCell *)cell forDisplayInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

- (void)collectionViewDidScroll:(UICollectionView *)collectionView;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id delegate;

@end
