//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat VExperienceEnhancerDesiredMinimumHeight;

@class VExperienceEnhancerBar;
@class VExperienceEnhancer;

@protocol VExperienceEnhancerBarDataSource <NSObject>

- (NSInteger)numberOfExperienceEnhancers;

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index;

@end

@protocol VExperienceEnhancerBarDelegate <NSObject>

- (void)didVoteWithExperienceEnhander:(VExperienceEnhancer *)experienceEnhancer;

- (void)didVoteWithExperienceEnhander:(VExperienceEnhancer *)experienceEnhancer targetPoint:(CGPoint)point;

@end

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, weak) id <VExperienceEnhancerBarDataSource> dataSource;

@property (nonatomic, weak) id <VExperienceEnhancerBarDelegate> delegate;

- (void)reloadData;

@property (nonatomic, copy) void (^selectionBlock)(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter);

@end
