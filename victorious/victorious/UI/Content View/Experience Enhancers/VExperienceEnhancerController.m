//
//  VExperienceEnhancerController.m
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerController.h"

#import "VExperienceEnhancer.h"

#import "VSequence.h"

@interface VExperienceEnhancerController ()

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong) NSArray *testEnhancers;

@end

@implementation VExperienceEnhancerController

#pragma mark - Factory Methods

+ (instancetype)experienceEnhancerControllerForSequence:(VSequence *)sequence
{
    VExperienceEnhancerController *experienceEnhancerControllerForSequence = [[VExperienceEnhancerController alloc] init];
    
    experienceEnhancerControllerForSequence.sequence = sequence;
    
    VExperienceEnhancer *lisaEnhancer = [[VExperienceEnhancer alloc] init];
    lisaEnhancer.icon = [UIImage imageNamed:@"eb_bacon"];
    lisaEnhancer.labelText = @"123";
    lisaEnhancer.animationDuration = 0.5f;
    NSMutableArray *animationImages = [NSMutableArray new];
    for (int i = 1; i <= 6; i++)
    {
        NSString *animationName = [NSString stringWithFormat:@"tumblr_mkyb94qEFr1s5jjtzo1_400-%i (dragged)", i];
        [animationImages addObject:[UIImage imageNamed:animationName]];
    }
    lisaEnhancer.animationSequence = animationImages;
    
    VExperienceEnhancer *fireworkEnhancer = [[VExperienceEnhancer alloc] init];
    fireworkEnhancer.icon = [UIImage imageNamed:@"eb_firework"];
    fireworkEnhancer.labelText = @"143";

    VExperienceEnhancer *thumbsUpEnhancer = [[VExperienceEnhancer alloc] init];
    thumbsUpEnhancer.icon = [UIImage imageNamed:@"eb_thumbsup"];
    thumbsUpEnhancer.labelText = @"321";

    VExperienceEnhancer *tongueEnhancer = [[VExperienceEnhancer alloc] init];
    tongueEnhancer.icon = [UIImage imageNamed:@"eb_tongueout"];
    tongueEnhancer.labelText = @"555";

    VExperienceEnhancer *tomatoEnhancer = [[VExperienceEnhancer alloc] init];
    tomatoEnhancer.ballistic = YES;
    tomatoEnhancer.flightImage = [UIImage imageNamed:@"Tomato0"];
    tomatoEnhancer.flightDuration = 0.5f;
    
    tomatoEnhancer.animationDuration = 0.75f;
    tomatoEnhancer.icon = [UIImage imageNamed:@"Tomato"];
    tomatoEnhancer.labelText = @"🍹";
    NSMutableArray *tomatoSequence = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 17; i++)
    {
        NSString *tomatoImage = [NSString stringWithFormat:@"Tomato%li", (long)i];
        [tomatoSequence addObject:[[UIImage imageNamed:tomatoImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    tomatoEnhancer.animationSequence = tomatoSequence;
  
    
    experienceEnhancerControllerForSequence.testEnhancers = @[lisaEnhancer, tomatoEnhancer, fireworkEnhancer, thumbsUpEnhancer, tongueEnhancer, lisaEnhancer, tomatoEnhancer, lisaEnhancer, tomatoEnhancer];
    
    return experienceEnhancerControllerForSequence;
}

#pragma mark - Property Accessors

- (void)setEnhancerBar:(VExperienceEnhancerBar *)enhancerBar
{
    _enhancerBar = enhancerBar;
    
    enhancerBar.dataSource = self;
}

#pragma mark - VExperienceEnhancerBarDataSource

- (NSInteger)numberOfExperienceEnhancers
{
    return (NSInteger)self.testEnhancers.count;
}

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index
{
    return [self.testEnhancers objectAtIndex:(NSUInteger)index];
}

@end
