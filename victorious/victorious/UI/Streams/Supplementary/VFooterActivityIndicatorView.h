//
//  VFooterActivityIndicatorView.h
//  victorious
//
//  Created by Patrick Lynch on 2/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFooterActivityIndicatorView : UICollectionReusableView

+ (NSString *)reuseIdentifier;

+ (UINib *)nibForSupplementaryView;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)collectionViewBounds;

- (void)setActivityIndicatorVisible:(BOOL)visible animated:(BOOL)animated;

@end
