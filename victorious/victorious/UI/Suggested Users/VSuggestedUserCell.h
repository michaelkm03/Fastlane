//
//  VSuggestedUserCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBackgroundContainer.h"
#import "VDependencyManager.h"
#import "VBaseCollectionViewCell.h"

@class VUser;

/**
 Collection cell designed to show some user info and a child collection view of
 sequences thumbnails as part of a suggested users screen.
 */
@interface VSuggestedUserCell : VBaseCollectionViewCell <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VUser *user;

@end
