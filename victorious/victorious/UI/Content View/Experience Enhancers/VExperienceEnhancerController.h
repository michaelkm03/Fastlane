//
//  VExperienceEnhancerController.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VExperienceEnhancerBar.h"
#import "VVideoCellViewModel.h"

@protocol VExperienceEnhancerControllerDelegate <NSObject>

- (void)experienceEnhancersDidUpdate;

@property (nonatomic, assign, readonly) Float64 currentVideoTime;

@end

@class VSequence;

@interface VExperienceEnhancerController : NSObject <VExperienceEnhancerBarDataSource, VExperienceEnhancerBarDelegate>

- (instancetype)initWithSequence:(VSequence *)sequence;

- (void)updateData;

@property (nonatomic, strong, readonly) VSequence *sequence;

@property (nonatomic, weak) VExperienceEnhancerBar *enhancerBar;

@property (nonatomic, weak) id<VExperienceEnhancerControllerDelegate> delegate;

@end
