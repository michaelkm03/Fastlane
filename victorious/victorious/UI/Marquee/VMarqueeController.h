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

@class VAbstractMarqueeCollectionViewCell, Shelf;

/**
    Classes that conform to this protocol will manage a marquee's display
        based on the provided dependency manager and shelf.
 */
@protocol VMarqueeController <NSObject, VHasManagedDependencies>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide a fully configured marquee cell for use in the provided collectionView.
 This should use the same reuse identifier
 */
- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 Provide the desired size for the collection view that this marquee controller manages.
 In most instances, subclasses should just return the desired size of their
 associated VAbstractMarqueeCollectionViewCell subclass
 
 @return A CGSize corresponding to the desired size of the collection view that this marquee controller manages
 */
- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

/**
 Register the proper VAbstractMarqueeCollectionViewCell subclass with the provided collectionView.
 */
- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView;

/**
 Provide an appropriate subclass of VAbstractMarqueeStreamItemCell whose reuse will be managed by this class.
 */
+ (Class)marqueeStreamItemCellClass;

/**
 Should be used to send -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
 messages to the collection view. Should be called as soon as the collection view is initialized.
 */
- (void)registerStreamItemCellsWithCollectionView:(UICollectionView *)collectionView forMarqueeItems:(NSArray *)marqueeItems;

/**
 Sets up the marquee with the provided shelf. The shelf's items will be KVO'd to keep the marquee properly updated.
 */
- (void)setShelf:(Shelf *)shelf;

/**
 Sets the delegate that will be called when content is selected from the marquee.
 */
- (void)setSelectionDelegate:(id <VMarqueeSelectionDelegate> __nullable)selectionDelegate;

/**
 Sets the delegate that will be called when data changes in the marquee.
 */
- (void)setDataDelegate:(id <VMarqueeDataDelegate> __nullable)dataDelegate;

NS_ASSUME_NONNULL_END

@end
