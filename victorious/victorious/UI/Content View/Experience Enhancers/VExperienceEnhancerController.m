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

static const NSTimeInterval kDefaultExperienceEnhancerAnimationDuration = 0.75f;

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
    

    NSMutableArray *fireworkAnimationImages = [NSMutableArray new];
    for (int i = 5; i <= 20; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"Firework_v01.%05d.png", i];
        [fireworkAnimationImages addObject:[UIImage imageNamed:imageName]];
    }
    VExperienceEnhancer *fireworkEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_firework"]
                                                                                  labelText:@"1.77K"
                                                                          animationSequence:fireworkAnimationImages
                                                                          animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                                isBallistic:YES
                                                                            shouldLetterBox:YES
                                                                             flightDuration:0.35
                                                                                flightImage:[UIImage imageNamed:@"Firework_v01.00000.png"]];
    
    NSMutableArray *lolAnimationImages = [NSMutableArray new];
    for (int i = 0; i <= 24; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"LOL_v02.%05d.png", i];
        [lolAnimationImages addObject:[UIImage imageNamed:imageName]];
    }
    VExperienceEnhancer *lolEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_lol"]
                                                                             labelText:@"2K"
                                                                     animationSequence:lolAnimationImages
                                                                     animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                           isBallistic:NO
                                                                       shouldLetterBox:YES
                                                                        flightDuration:0.0f
                                                                           flightImage:nil];
    
    NSMutableArray *glitterImages = [NSMutableArray new];
    for (int i = 0; i <= 30; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"GLITTER_V01.%05d.png", i];
        [glitterImages addObject:[UIImage imageNamed:imageName]];
    }
    VExperienceEnhancer *glitterEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_glitter"]
                                                                                 labelText:@"19K"
                                                                         animationSequence:glitterImages
                                                                         animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                               isBallistic:NO
                                                                           shouldLetterBox:NO
                                                                            flightDuration:0.0f
                                                                               flightImage:nil];
    NSMutableArray *lightningImages = [NSMutableArray new];
    for (int i = 0; i <= 19; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"Lightening_V01.%05d.png", i];
        [lightningImages addObject:[UIImage imageNamed:imageName]];
    }
    
    VExperienceEnhancer *lightningEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_lightning"]
                                                                                   labelText:@"99M"
                                                                           animationSequence:lightningImages
                                                                           animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                                 isBallistic:NO
                                                                             shouldLetterBox:NO
                                                                              flightDuration:0.0f
                                                                                 flightImage:nil];

    NSMutableArray *waterBalloonAnimation = [NSMutableArray new];
    for (int i = 0; i <= 26; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"WATERBALLOON_V01.%05d.png", i];
        [waterBalloonAnimation addObject:[UIImage imageNamed:imageName]];
    }
    VExperienceEnhancer *waterBaloonEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_waterballoon"]
                                                                                     labelText:@"5B"
                                                                             animationSequence:waterBalloonAnimation
                                                                             animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                                   isBallistic:NO
                                                                               shouldLetterBox:NO
                                                                                flightDuration:0.0f
                                                                                   flightImage:nil];
    
    NSMutableArray *lisaAnimation = [NSMutableArray new];
    for (int i = 1; i <= 6; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"tumblr_mkyb94qEFr1s5jjtzo1_400-%i", i];
        [lisaAnimation addObject:[UIImage imageNamed:imageName]];
    }
    VExperienceEnhancer *lisaEnhancer = [VExperienceEnhancer experienceEnhancerWithIcon:[UIImage imageNamed:@"eb_bacon"]
                                                                              labelText:@"742"
                                                                      animationSequence:lisaAnimation
                                                                      animationDuration:kDefaultExperienceEnhancerAnimationDuration
                                                                            isBallistic:NO
                                                                        shouldLetterBox:YES
                                                                         flightDuration:0.0f
                                                                            flightImage:nil];
    
    experienceEnhancerControllerForSequence.testEnhancers = @[fireworkEnhancer, lolEnhancer, glitterEnhancer, lightningEnhancer, waterBaloonEnhancer, lisaEnhancer];
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
