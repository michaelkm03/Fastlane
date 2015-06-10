//
//  VSuggestedUsersHeaderCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDependencyManager.h"

@interface VSuggestedUsersHeaderCell : UICollectionViewCell

+ (NSString *)suggestedReuseIdentifier;

- (void)setDependencyManager:(VDependencyManager *)dependencyManager;

- (void)setMessage:(NSString *)message;

@end
