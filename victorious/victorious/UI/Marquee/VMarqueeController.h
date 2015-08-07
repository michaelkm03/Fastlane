//
//  VMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"
#import "VMarqueeSelectionDelegate.h"
#import "VMarqueeDataDelegate.h"

@class VAbstractMarqueeCollectionViewCell, VShelf;

@protocol VMarqueeController <NSObject, VHasManagedDependencies>

/**
 Overridden by subclasses to provide a fully configured marquee cell for use in the provided collectionView.
 This should use the same reuse identifier
 */
- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 Overridden by subclasses to surface the desired size for the collection view that this marquee controller manages.
 In most instances, subclasses should just return the desired size of their
 associated VAbstractMarqueeCollectionViewCell subclass
 
 @return A CGSize corresponding to the desired size of the collection view that this marquee controller manages
 */
- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

/**
 Overridden by subclasses to register the proper VAbstractMarqueeCollectionViewCell subclass with the provided collectionView.
 */
- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView;

/**
 Overridden by subclasses to provide an appropriate subclass of VAbstractMarqueeStreamItemCell whose reuse will be managed by this class.
 */
+ (Class)marqueeStreamItemCellClass;

/**
 Sends -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
 messages to the collection view. Should be called as soon as the collection view is initialized.
 */
- (void)registerStreamItemCellsWithCollectionView:(UICollectionView *)collectionView forMarqueeItems:(NSArray *)marqueeItems;

- (void)setShelf:(VShelf *)shelf;

- (void)setSelectionDelegate:(id <VMarqueeSelectionDelegate>)selectionDelegate;

- (void)setDataDelegate:(id <VMarqueeDataDelegate>)dataDelegate;

@end
