//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat VExperienceEnhancerDesiredMinimumHeight;
extern NSString * const VExperienceEnhancerBarDidRequirePurcahsePrompt;
extern NSString * const VExperienceEnhancerBarDidRequireLoginNotification;

@class VExperienceEnhancerBar;
@class VExperienceEnhancer;

@protocol VExperienceEnhancerBarDataSource <NSObject>

- (NSInteger)numberOfExperienceEnhancers;

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index;

@end

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, weak) id <VExperienceEnhancerBarDataSource> dataSource;

- (void)reloadData;

@property (nonatomic, copy) void (^selectionBlock)(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter);

@end
