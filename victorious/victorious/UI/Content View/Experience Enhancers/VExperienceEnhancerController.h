//
//  VExperienceEnhancerController.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VExperienceEnhancerBar.h"

@protocol VExperienceEnhancerControllerDelegate <NSObject>

- (void)experienceEnhancersDidUpdate;

@end

@class VSequence;

@interface VExperienceEnhancerController : NSObject <VExperienceEnhancerBarDataSource>

- (instancetype)initWithSequence:(VSequence *)sequence;

- (void)sendTrackingEvents;

- (void)updateData;

@property (nonatomic, strong, readonly) VSequence *sequence;

@property (nonatomic, weak) VExperienceEnhancerBar *enhancerBar;

@property (nonatomic, weak) id<VExperienceEnhancerControllerDelegate> delegate;

@end
