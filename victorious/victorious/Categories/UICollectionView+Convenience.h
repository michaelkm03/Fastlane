//
//  UICollectionView+Convenience.h
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Convenience)

/**
 *  Returns the indexPaths in the passed in rect relative to the collection view.
 */
- (NSArray *)indexPathsInRect:(CGRect)rect;

@end
