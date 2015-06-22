//
//  VUserCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser, VDependencyManager;

/**
 A collection view cell designed to display profile, name and other information about a user.
 Also includes a follow toggle button so that the user can be followed or unfollowed when
 displayed in a collection view.
 */
@interface VUserCell : UICollectionViewCell

+ (NSString *)suggestedReuseIdentifier;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

- (void)setUser:(VUser *)user;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
