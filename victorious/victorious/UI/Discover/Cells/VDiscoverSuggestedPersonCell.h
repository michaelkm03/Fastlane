//
//  VDiscoverSuggestedPersonCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUser.h"

@class VDependencyManager;

@interface VDiscoverSuggestedPersonCell : UICollectionViewCell

@property (nonatomic, strong) VUser *user;

- (void)populateData;
- (void)setUser:(VUser *)user
       animated:(BOOL)animated;

+ (CGFloat)cellHeight;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
