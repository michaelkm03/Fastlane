//
//  VExperienceEnhancerController.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VExperienceEnhancerBar.h"
#import "VHasManagedDependencies.h"

@protocol VExperienceEnhancerControllerDelegate <NSObject>

- (void)experienceEnhancersDidUpdate;

@property (nonatomic, assign, readonly) Float64 currentVideoTime;

@property (nonatomic, assign, readonly) BOOL isVideoContent;

@end

@class VSequence;

@interface VExperienceEnhancerController : NSObject <VExperienceEnhancerBarDataSource, VExperienceEnhancerBarDelegate, VHasManagedDependencies>

// Only visible for swift compatibility
+ (NSCache *)imageMemoryCache;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)updateData;

@property (nonatomic, strong, readonly) VSequence *sequence;

@property (nonatomic, weak) VExperienceEnhancerBar *enhancerBar;

@property (nonatomic, weak) id<VExperienceEnhancerControllerDelegate> delegate;

@end
