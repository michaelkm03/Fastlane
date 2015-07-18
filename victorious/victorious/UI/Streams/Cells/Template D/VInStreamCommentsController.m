//
//  VInStreamCommentsController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsController.h"
#import "VInStreamCommentsCell.h"
#import "VInStreamCommentsShowMoreCell.h"
#import "VInStreamCommentsShowMoreAttributes.h"
#import "VTagSensitiveTextView.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

static CGFloat const kMinimumInterItemSpace = 4.0f;
static UIEdgeInsets const kSectionEdgeInsets = { 0.0f, 27.0f, 6.0f, 2.0f };

@interface VInStreamCommentsController () <CCHLinkTextViewDelegate>

@property (nonatomic, strong) NSArray *commentCellContents;
@property (nonatomic, assign) BOOL showMoreCellVisible;

@end

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
    self.collectionView.contentInset = kSectionEdgeInsets;
    for ( NSString *identifier in [VInStreamCommentsCell possibleReuseIdentifiers] )
    {
        [self.collectionView registerNib:[VInStreamCommentsCell nibForCell] forCellWithReuseIdentifier:identifier];
    }
    [self.collectionView registerNib:[VInStreamCommentsShowMoreCell nibForCell] forCellWithReuseIdentifier:[VInStreamCommentsShowMoreCell suggestedReuseIdentifier]];
}

- (void)setupWithCommentCellContents:(NSArray *)commentCellContents withShowMoreCellVisible:(BOOL)visible
{
    BOOL contentsNeedUpdate = ![self.commentCellContents isEqualToArray:commentCellContents];
    BOOL showMoreCellNeedsUpdate = self.showMoreCellVisible != visible;
    if ( contentsNeedUpdate || showMoreCellNeedsUpdate )
    {
        self.commentCellContents = commentCellContents;
        self.showMoreCellVisible = visible;
        [self.collectionView reloadData];
    }
}

+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents withCollectionViewWidth:(CGFloat)width showMoreAttributes:(VInStreamCommentsShowMoreAttributes *)attributes andShowPreviousCommentsCellEnabled:(BOOL)enabled
{
    CGFloat height = 0.0f;
    width -= kSectionEdgeInsets.right + kSectionEdgeInsets.left;
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
    
    if ( enabled )
    {
        height += kMinimumInterItemSpace;
        height += [VInStreamCommentsShowMoreCell desiredHeightForAttributes:attributes
                                                               withMaxWidth:width];
    }
    if ( loopedOnce )
    {
        height += kSectionEdgeInsets.top + kSectionEdgeInsets.bottom;
    }
    
    return height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = self.commentCellContents.count;
    if ( count == 0 )
    {
        return 0;
    }
    
    if ( self.showMoreCellVisible )
    {
        count++;
    }
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self isShowMoreCellIndexPath:indexPath] )
    {
        //Return the "see more" cell
        VInStreamCommentsShowMoreCell *seeMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInStreamCommentsShowMoreCell suggestedReuseIdentifier] forIndexPath:indexPath];
        [seeMoreCell setupWithAttributes:self.showMoreAttributes andLinkDelegate:self];
        return seeMoreCell;
    }
    VInStreamCommentCellContents *contents = self.commentCellContents[indexPath.row];
    NSString *identifier = [VInStreamCommentsCell reuseIdentifierForContents:contents];
    VInStreamCommentsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setupWithInStreamCommentCellContents:contents];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    UIEdgeInsets insets = collectionView.contentInset;
    width -= insets.left + insets.right;
    
    CGFloat height = 0;
    if ( [self isShowMoreCellIndexPath:indexPath] )
    {
        height = [VInStreamCommentsShowMoreCell desiredHeightForAttributes:self.showMoreAttributes withMaxWidth:width];
    }
    else
    {
        height = [[self class] cellHeightForContent:self.commentCellContents[indexPath.row] withCellWidth:width];
    }
    return CGSizeMake(width, height);
}

- (BOOL)isShowMoreCellIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == (NSInteger)self.commentCellContents.count;
}

+ (CGFloat)cellHeightForContent:(VInStreamCommentCellContents *)content withCellWidth:(CGFloat)width
{
    return [VInStreamCommentsCell desiredHeightForCommentCellContents:content withMaxWidth:width];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMinimumInterItemSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

@end
