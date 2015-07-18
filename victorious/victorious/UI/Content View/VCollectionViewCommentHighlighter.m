//
//  VCollectionViewCommentHighlighter.m
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCollectionViewCommentHighlighter.h"
#import "VContentCommentsCell.h"

@interface VCollectionViewCommentHighlighter ()

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VCollectionViewCommentHighlighter

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if ( self != nil )
    {
        _collectionView = collectionView;
    }
    return self;
}

- (NSInteger)numberOfSections
{
    return self.collectionView.numberOfSections;
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (UIView *)viewToAnimateForIndexPath:(NSIndexPath *)indexPath
{
    VContentCommentsCell *cell = (VContentCommentsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ( cell == nil || ![cell isKindOfClass:[VContentCommentsCell class]] )
    {
        return nil;
    }
    return cell;
}

@end
