//
//  VSuggestedPeopleCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeopleCell.h"

@implementation VSuggestedPeopleCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    if ( self.collectionView == nil )
    {
        _collectionView = collectionView;
        [self addSubview:_collectionView];
        _collectionView.frame = self.bounds;
        //[self applyConstraints];
    }
}

- (void)applyConstraints
{
    /*self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{ @"subview" : self.collectionView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];*/
}

+ (NSInteger)cellHeight
{
    return 190.0f;
}

@end
