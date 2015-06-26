//
//  VSuggestedUserRetryCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VBackgroundContainer.h"

@class VDependencyManager;

typedef NS_ENUM(NSUInteger, VSuggestedUserRetryCellState)
{
    VSuggestedUserRetryCellStateDefault,
    VSuggestedUserRetryCellStateLoading
};

@interface VSuggestedUserRetryCell : VBaseCollectionViewCell <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) VSuggestedUserRetryCellState state;

@end
