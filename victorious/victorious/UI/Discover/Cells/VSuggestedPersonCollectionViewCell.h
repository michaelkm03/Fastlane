//
//  VSuggestedPersonCollectionViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUser.h"

@class VDependencyManager;

@interface VSuggestedPersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VUser *user;

- (void)setUser:(VUser *)user
       animated:(BOOL)animated;

+ (UIImage *)followedImage;
+ (UIImage *)followImage;
+ (CGFloat)cellHeight;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
