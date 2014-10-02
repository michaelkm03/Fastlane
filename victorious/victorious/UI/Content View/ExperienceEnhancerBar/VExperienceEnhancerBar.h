//
//  VExperienceEnhancerBar.h
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VExperienceEnhancerBar : UIView

+ (instancetype)experienceEnhancerBar;

@property (nonatomic, strong) NSArray *actionItems;

@property (nonatomic, copy) void (^pressedTextEntryHandler)(void);

@end
