//
//  VInStreamCommentsController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsController.h"
#import "VInStreamCommentsCell.h"
#import "VTagSensitiveTextView.h"

static CGFloat const kMinimumInterItemSpace = 4.0f;
static UIEdgeInsets const kSectionEdgeInsets = { 6.0f, 0.0f, 12.0f, 0.0f };

@implementation VInStreamCommentsController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if ( self != nil )
    {
        _collectionView = collectionView;
        [self setupCollectionView];
    }
    return self;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[VInStreamCommentsCell nibForCell] forCellWithReuseIdentifier:[VInStreamCommentsCell suggestedReuseIdentifier]];
}

+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents withCollectionViewWidth:(CGFloat)width withShowPreviousCommentsCellEnabled:(BOOL)enabled
{
    CGFloat height = 0.0f;
    BOOL loopedOnce = NO;
    for ( VInStreamCommentCellContents *content in commentCellContents )
    {
        height += [[self class] cellHeightForContent:content withCellWidth:width];
        if ( loopedOnce )
        {
            height += kMinimumInterItemSpace;
        }
        loopedOnce = YES;
    }
    if ( loopedOnce )
    {
        height += kSectionEdgeInsets.top + kSectionEdgeInsets.bottom;
    }
    return height;
}

- (void)setCommentCellContents:(NSArray *)commentCellContents
{
    if ( [_commentCellContents isEqualToArray:commentCellContents] )
    {
        return;
    }
    
    _commentCellContents = commentCellContents;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.commentCellContents.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VInStreamCommentsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInStreamCommentsCell suggestedReuseIdentifier] forIndexPath:indexPath];
    [cell setupWithInStreamCommentCellContents:self.commentCellContents[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(width, [[self class] cellHeightForContent:self.commentCellContents[indexPath.row] withCellWidth:width]);
}

+ (CGFloat)cellHeightForContent:(VInStreamCommentCellContents *)content withCellWidth:(CGFloat)width
{
    return [VInStreamCommentsCell desiredHeightForCommentCellContents:content withMaxWidth:width];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kMinimumInterItemSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMinimumInterItemSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return kSectionEdgeInsets;
}

@end
