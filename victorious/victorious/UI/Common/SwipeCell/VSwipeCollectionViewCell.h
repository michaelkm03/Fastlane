//
//  VSwipeCollectionViewCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeViewController.h"

@interface VSwipeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VSwipeViewController *swipeViewController;

- (void)setupSwipeView;

@end
