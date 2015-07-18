//
//  VInStreamCommentsController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VInStreamCommentCellContents, VInStreamCommentsShowMoreAttributes;

@interface VInStreamCommentsController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents
                       withCollectionViewWidth:(CGFloat)width
                            showMoreAttributes:(VInStreamCommentsShowMoreAttributes *)attributes
            andShowPreviousCommentsCellEnabled:(BOOL)enabled;

- (void)setupWithCommentCellContents:(NSArray *)commentCellContents withShowMoreCellVisible:(BOOL)visible;

@property (nonatomic, strong) VInStreamCommentsShowMoreAttributes *showMoreAttributes;
@property (nonatomic, strong) UICollectionView *collectionView;

@end
