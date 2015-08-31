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

/**
 Collection cell designed to look like the VSuggestedUserCell and provide prompts for
 tapping to reload and show an indicator when content is loading.
 */
@interface VSuggestedUserRetryCell : VBaseCollectionViewCell <VBackgroundContainer>

/**
 The dependency manager used to style this cell.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 The state of this cell. Updating this property will hide or show the loading state of this cell.
 */
@property (nonatomic, assign) VSuggestedUserRetryCellState state;

@end
