//
//  VRotationHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRotationHelper : NSObject

@property (nonatomic, assign, readonly) BOOL isLandscape;

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
                         targetContentOffset:(CGPoint)targetContentOffset
                              collectionView:(UICollectionView *)collectionView
                        landscapeHiddenViews:(NSArray *)landscapeHiddenViews;

@end
