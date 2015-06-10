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

@class VUser;

@interface VSuggestedUserCell : UICollectionViewCell <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (NSString *)suggestedReuseIdentifier;

- (void)setUser:(VUser *)user;

@end
