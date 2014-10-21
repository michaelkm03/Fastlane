//
//  VExperienceEnhancer.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancer.h"

@implementation VExperienceEnhancer

<<<<<<< HEAD
- (BOOL)hasRequiredImages
{
    if ( self.isBallistic )
    {
        return self.flightImage != nil;
    }
    else
    {
        return self.iconImage != nil && self.animationSequence != nil && self.animationSequence.count > 0;
    }
=======
+ (instancetype)experienceEnhancerWithIcon:(UIImage *)icon
                                 labelText:(NSString *)labelText
                         animationSequence:(NSArray *)animationSequence
                         animationDuration:(NSTimeInterval)animationDuration
                               isBallistic:(BOOL)ballistic
                           shouldLetterBox:(BOOL)shouldLetterBox
                            flightDuration:(NSTimeInterval)flightDuration
                               flightImage:(UIImage *)flightImage
{
    VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] init];
    
    enhancer.icon = icon;
    enhancer.labelText = labelText;
    enhancer.animationSequence = animationSequence;
    enhancer.animationDuration = animationDuration;
    enhancer.ballistic = ballistic;
    enhancer.shouldLetterBox = shouldLetterBox;
    enhancer.flightDuration = flightDuration;
    enhancer.flightImage = flightImage;
    
    return enhancer;
>>>>>>> 76e0e4c4c7a9ab1883da9d82867e0f9f3629d26c
}

@end
