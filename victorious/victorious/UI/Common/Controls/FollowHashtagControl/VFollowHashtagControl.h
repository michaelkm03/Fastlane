//
//  VFollowHashtagControl.h
//  victorious
//
//  Created by Lawrence Leach on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VFollowHashtagControl : UIControl

@property (nonatomic, assign) BOOL subscribed;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (void)setSubscribed:(BOOL)subscribed
             animated:(BOOL)animated;

@end
