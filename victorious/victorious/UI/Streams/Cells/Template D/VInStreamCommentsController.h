//
//  VInStreamCommentsController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VInStreamCommentCellContents;

@interface VInStreamCommentsController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents withCollectionViewWidth:(CGFloat)width withShowPreviousCommentsCellEnabled:(BOOL)enabled;

@property (nonatomic, strong) NSArray *commentCellContents;
@property (nonatomic, strong) UICollectionView *collectionView;

@end
