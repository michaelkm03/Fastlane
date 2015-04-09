//
//  VContentViewRotationHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @abstract A convenient helper for managing rotation with VNewContentViewController.
 */
@interface VContentViewRotationHelper : NSObject

/**
 *  @abstract Indicates whether or not the last handle... method was to a landscape orientation.
 */
@property (nonatomic, assign, readonly) BOOL isLandscape;

/**
 *  @abstract Use this to manage a collection view its offset and other views associated with a VNewContentViewController.
 *
 *  @discussion This method attempts to preserve the content offset when rotating and hides views passed in to affectedViews.
 *
 *  @param toInterfaceOrientation The target interface orientation.
 *
 *  @param targetContentOffset The content offset to preserve between portrait -> landscape -> portrait rotations. Ignored when toInterfaceOrientation is landscape.
 *
 *  @param collectionView The collectionView to apply contentOffset chagnes to.
 *
 *  @param affectedViews The views to hide when in landscape.
 *
 */
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                         targetContentOffset:(CGPoint)targetContentOffset
                              collectionView:(UICollectionView *)collectionView
                               affectedViews:(NSArray *)affectedViews;

@end
