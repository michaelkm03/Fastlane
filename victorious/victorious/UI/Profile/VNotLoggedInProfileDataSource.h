//
//  VNotLoggedInProfileDataSource.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VNotLoggedInProfileDataSource;

@protocol VNotLoggedInProfileDataSourceDelegate <NSObject>

- (void)VNotLoggedInProfileDataSourceWantsLogin:(VNotLoggedInProfileDataSource *)notLoggedInDataSource;

@end

@interface VNotLoggedInProfileDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
