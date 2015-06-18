//
//  VUserCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser, VDependencyManager;

@interface VUserCell : UICollectionViewCell

+ (NSString *)suggestedReuseIdentifier;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

- (void)setUser:(VUser *)user;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
