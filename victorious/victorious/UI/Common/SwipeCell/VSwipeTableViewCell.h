//
//  VSwipeTableViewCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSwipeView.h"

@interface VSwipeTableViewCell : UITableViewCell <VSwipeViewCellDelegate>

@property (nonatomic, strong) VSwipeView *swipeView;

@end
