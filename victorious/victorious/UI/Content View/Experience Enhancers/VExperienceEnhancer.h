//
//  VExperienceEnhancer.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VExperienceEnhancer : NSObject

+ (instancetype)experienceEnhancerWithIconImage:(UIImage *)iconImage
                                      labelText:(NSString *)labelText
                              animationSequence:(NSArray *)animationSequence
                              animationDuration:(NSTimeInterval)animationDuration
                                    isBallistic:(BOOL)ballistic
                                shouldLetterBox:(BOOL)shouldLetterBox
                                 flightDuration:(NSTimeInterval)flightDuration
                                    flightImage:(UIImage *)flightImage;

@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, copy) NSString *labelText;

//TODO: Lazily load these
@property (nonatomic, strong) NSArray *animationSequence;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign, getter = isBallistic) BOOL ballistic;
@property (nonatomic, assign) BOOL shouldLetterBox;
@property (nonatomic, assign) NSTimeInterval flightDuration;
@property (nonatomic, strong) UIImage *flightImage;

@property (nonatomic, readonly) BOOL hasRequiredImages;

@end
