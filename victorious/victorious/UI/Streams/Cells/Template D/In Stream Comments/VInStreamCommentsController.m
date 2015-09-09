//
//  VInStreamCommentsController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsController.h"
#import "VInStreamCommentsCell.h"
#import "VInStreamCommentsShowMoreAttributes.h"
#import "VTagSensitiveTextView.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>
#import "VComment.h"
#import "VInStreamCommentCellContents.h"
#import "VInStreamCommentsResponder.h"
#import "VInStreamCommentsShowMoreCell.h"

static CGFloat const kMinimumInterItemSpace = 10.0f;
static UIEdgeInsets const kSectionEdgeInsets = { 0.0f, 0.0f, 0.0f, 2.0f };

@interface VInStreamCommentsController () <CCHLinkTextViewDelegate>

@property (nonatomic, strong) NSArray *commentCellContents;
@property (nonatomic, assign) BOOL showMoreCellVisible;

@end

@implementation VInStreamCommentsController

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    NSParameterAssert(collectionView != nil);
    
    self = [super init];
    if ( self != nil )
    {
        _collectionView = collectionView;
        _leftInset = kSectionEdgeInsets.left;
        [self setupCollectionView];
    }
    return self;
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)setLeftInset:(CGFloat)leftInset
{
    BOOL needsUpdate = _leftInset != leftInset;
    _leftInset = leftInset;
    if ( needsUpdate )
    {
        UIEdgeInsets contentInset = self.collectionView.contentInset;
        contentInset.left = leftInset;
        self.collectionView.contentInset = contentInset;
        [self.collectionView reloadData];
    }
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

+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents withMaxWidth:(CGFloat)width showMoreAttributes:(VInStreamCommentsShowMoreAttributes *)attributes andShowMoreCommentsCellEnabled:(BOOL)enabled
{
    CGFloat height = 0.0f;
    width -= kSectionEdgeInsets.right + kSectionEdgeInsets.left;
    BOOL loopedOnce = NO;
    for ( VInStreamCommentCellContents *content in commentCellContents )
    {
        height += [[self class] cellHeightForContent:content withCellWidth:width];
        height += kMinimumInterItemSpace;
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
    
    CGFloat height = 0.0f;
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

#pragma mark - Interaction response

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    VComment *comment = nil;
    if ( [cell isKindOfClass:[VInStreamCommentsCell class]] )
    {
        comment = ((VInStreamCommentsCell *)cell).commentCellContents.comment;
    }
    
    [self performActionForSelectedComment:comment fromSequence:[self sequence]];
}

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    //Triggered from the "show more" cell, ask responder chain to show the comments screen.
    [self performActionForSelectedComment:nil fromSequence:[self sequence]];
}

- (VSequence *)sequence
{
    if ( self.commentCellContents.count > 0 )
    {
        VComment *comment = ((VInStreamCommentCellContents *)self.commentCellContents.firstObject).comment;
        return comment.sequence ?: comment.inStreamSequence;
    }
    return nil;
}

#pragma mark - Responder chain helpers

- (void)performActionForSelectedComment:(VComment *)comment fromSequence:(VSequence *)sequence
{
    if ( sequence == nil )
    {
        return;
    }
    
    id<VInStreamCommentsResponder> commentsResponder = [[self.collectionView nextResponder] targetForAction:@selector(actionForInStreamCommentSelection:fromSequence:)
                                                                                                 withSender:nil];
    NSAssert(commentsResponder != nil, @"VInStreamCommentsController needs a VInStreamCommentsResponder higher up the chain to communicate following commands with.");
    [commentsResponder actionForInStreamCommentSelection:comment fromSequence:sequence];
}

@end
