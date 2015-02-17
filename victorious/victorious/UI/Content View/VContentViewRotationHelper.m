//
//  VContentViewRotationHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewRotationHelper.h"

@interface VContentViewRotationHelper()

@property (nonatomic, assign) CGPoint preRotationContentOffset;
@property (nonatomic, assign, readwrite) BOOL isLandscape;

@end

@implementation VContentViewRotationHelper

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                         targetContentOffset:(CGPoint)targetContentOffset
                              collectionView:(UICollectionView *)collectionView
                        affectedViews:(NSArray *)affectedViews
{
    self.isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    [affectedViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
     {
         view.hidden = self.isLandscape;
     }];
    
    if ( self.isLandscape )
    {
        self.preRotationContentOffset = collectionView.contentOffset;
        [collectionView setContentOffset:targetContentOffset animated:NO];
        collectionView.scrollEnabled = NO;
    }
    else if ( !CGPointEqualToPoint( self.preRotationContentOffset, CGPointZero ) )
    {
        [collectionView setContentOffset:self.preRotationContentOffset animated:NO];
        collectionView.scrollEnabled = YES;
    }
}

@end
