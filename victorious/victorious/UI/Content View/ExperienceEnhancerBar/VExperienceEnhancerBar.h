//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat VExperienceEnhancerDesiredMinimumHeight;

@interface VExperienceEnhancer : NSObject;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, copy) void (^selectionBlock)(void);

@end

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, strong) NSArray *actionItems;

@property (nonatomic, copy) void (^pressedTextEntryHandler)(void);

@end
