//
//  VCollectionViewCommentHighlighter.h
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCommentHighlighter.h"

@interface VCollectionViewCommentHighlighter : VAbstractCommentHighlighter

/**
 The desginated initializer requiring a collectionView to work with so it can control
 animation of the contentOffset and cells within.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

@end
