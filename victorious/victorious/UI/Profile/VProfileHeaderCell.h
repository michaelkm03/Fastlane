//
//  VProfileHeaderCell.h
//  victorious
//
//  Created by Will Long on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUserProfileHeaderView.h"

@interface VProfileHeaderCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet VUserProfileHeaderView *headerView;
@property (nonatomic, weak) NSLayoutConstraint *headerViewHeightConstraint;

@end
