//
//  VAssetCollectionUnauthorizedDataSource.h
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VAssetCollectionUnauthorizedDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
