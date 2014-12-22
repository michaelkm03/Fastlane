//
//  VUtilityButtonsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeViewController.h"

@interface VUtilityButtonsViewController : UIViewController

// Call this whenever constraints are changed, it invalidates the collection view's layout
- (void)constraintsDidUpdate;

@property (weak, nonatomic) id<VSwipeViewCellDelegate> cellDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
