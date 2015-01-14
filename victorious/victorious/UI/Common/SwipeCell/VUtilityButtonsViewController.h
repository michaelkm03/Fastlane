//
//  VUtilityButtonsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeViewController.h"

@protocol VUtilityButtonsViewControllerDelegate <NSObject>

- (void)utilityButtonSelected;

@property (nonatomic, readonly) id<VSwipeViewCellDelegate> cellDelegate;

@end

/**
 Controller for the collection view of utility buttons that appears in VSwipeTableViewCell
 */
@interface VUtilityButtonsViewController : UIViewController

- (instancetype)initWithFrame:(CGRect)frame;

// Call this whenever constraints are changed, it invalidates the collection view's layout
- (void)constraintsDidUpdate;

@property (weak, nonatomic) id<VUtilityButtonsViewControllerDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectionView;

@end
