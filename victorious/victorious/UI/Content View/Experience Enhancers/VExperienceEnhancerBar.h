//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat VExperienceEnhancerDesiredMinimumHeight;

@class VExperienceEnhancerBar;
@class VExperienceEnhancer;
@class VDependencyManager;

@protocol VExperienceEnhancerBarDataSource <NSObject>

- (NSInteger)numberOfExperienceEnhancers;

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index;

@end

@protocol VExperienceEnhancerBarDelegate <NSObject>

@optional

- (void)experienceEnhancerSelected:(VExperienceEnhancer *)enhancer;

@end

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, weak) id <VExperienceEnhancerBarDataSource> dataSource;
@property (nonatomic, weak) id <VExperienceEnhancerBarDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, copy) void (^selectionBlock)(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter);

@property (nonatomic, strong) VDependencyManager *dependencyManager;
- (void)reloadData;

@end
