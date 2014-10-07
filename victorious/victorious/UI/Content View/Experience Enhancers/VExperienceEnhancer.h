//
//  VExperienceEnhancer.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VExperienceEnhancer : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *labelText;

@property (nonatomic, strong) NSArray *animationSequence;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign, getter = isBallistic) BOOL ballistic;
@property (nonatomic, assign) NSTimeInterval flightDuration;
@property (nonatomic, strong) UIImage *flightImage;

@end
