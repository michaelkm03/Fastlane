//
//  VContentViewRotationHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VContentViewRotationHelper : NSObject

@property (nonatomic, assign, readonly) BOOL isLandscape;

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                         targetContentOffset:(CGPoint)targetContentOffset
                              collectionView:(UICollectionView *)collectionView
                        affectedViews:(NSArray *)affectedViews;

@end
