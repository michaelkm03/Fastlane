//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat VExperienceEnhancerDesiredMinimumHeight;
extern NSString * const VExperienceEnhancerBarDidRequirePurchasePrompt;
extern NSString * const VExperienceEnhancerBarDidRequireLoginNotification;

@class VExperienceEnhancerBar;
@class VExperienceEnhancer;

@protocol VExperienceEnhancerBarDataSource <NSObject>

- (NSInteger)numberOfExperienceEnhancers;

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index;

@end

@protocol VExperienceEnhancerBarDelegate <NSObject>

- (void)experienceEnhancerSelected:(VExperienceEnhancer *)enhancer;

@end

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, weak) id <VExperienceEnhancerBarDataSource> dataSource;
@property (nonatomic, weak) id <VExperienceEnhancerBarDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;

- (void)reloadData;

@property (nonatomic, copy) void (^selectionBlock)(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter);

@end
