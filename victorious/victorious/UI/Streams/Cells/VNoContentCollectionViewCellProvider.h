//
//  VNoContentCollectionViewCellProvider.h
//  victorious
//
//  Created by Sharif Ahmed on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    A convenience object for checking for the ability to handle population from a model object and providing an error cell when appropriate
 */
@interface VNoContentCollectionViewCellProvider : NSObject

/**
    Creates a new no content collection view cell provider.
 
    @param acceptableClasses An array of classes that cells can populate from
 
    @return A new no content collection view cell provider
 */
- (instancetype)initWithAcceptableContentClasses:(NSArray *)acceptableClasses NS_DESIGNATED_INITIALIZER;

/**
    Registers no content cells with the provided collectionView
 
    @param collectionView The collection view that should display no content cells when appropriate
 */
- (void)registerNoContentCellWithCollectionView:(UICollectionView *)collectionView;

/**
    The desired size for the no content cell
 
    @param bounds The bounds of the collection view that will display the no content cell
 
    @return The desired size for the no content cell
 */
- (CGSize)cellSizeForCollectionViewBounds:(CGRect)bounds;

/**
    A no content cell dequed from the provided collectionView
 
    @param collectionView The collection view that will display the no content cell. This collectionView must be passed into
            registerNoContentCellWithCollectionView: before this function is called
    @param indexPath The index path where the no content cell will appear
 
    @return A no content cell
 */
- (UICollectionViewCell *)noContentCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
    Returns whether or not the model can be used to populate a stream cell
 
    @param contentClass The class of model that could trigger the appearance of a no content cell
 
    @return YES when a no content cell should be displayed
 */
- (BOOL)shouldDisplayNoContentCellForContentClass:(Class)contentClass;

/**
    Returns whether or not the provided cell is a no content cell
 
    @param collectionViewCell The collection view cell that should be checked for whether or not it is a no content cell
 
    @return YES when the provided cell is a no content cell
 */
+ (BOOL)isNoContentCell:(UICollectionViewCell *)collectionViewCell;

@end
