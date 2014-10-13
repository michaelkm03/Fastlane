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
#import "VVoteType.h"
#import "VVoteAction+RestKit.h"
#import "VSettingManager.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Private.h"
#import "UIImageView+AFNetworking.h"

/**
 This will switch between (0) using hardcoded experience enhancers that demonstrate
 the full range of animation capabilities and (1) using only the experience enhancers
 enabled by the server in its response to /api/init and the data each contains.
 */
// TODO: Remove this
#define USE_INIT_SETTINGS 1

@interface VExperienceEnhancerController ()

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong) NSArray *testEnhancers;

@end

@implementation VExperienceEnhancerController

#pragma mark - Factory Methods

+ (instancetype)experienceEnhancerControllerForSequence:(VSequence *)sequence
{
    return [[VExperienceEnhancerController alloc] initWithSequence:sequence];
}

#pragma mark - Initialization

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        self.sequence = sequence;
        
#if USE_INIT_SETTINGS
        NSArray *voteTypes = [[VSettingManager sharedManager] voteTypes];
        self.testEnhancers = [self createExperienceEnhancersFromVoteTypes:voteTypes];
#else
        self.testEnhancers = [self createTestingExperienceEnhancers];
#endif
    }
    return self;
}

- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes
{
    NSMutableArray *experienceEnhanders = [[NSMutableArray alloc] init];
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop) {
        [experienceEnhanders addObject:[self experienceEnhancerFromVoteType:voteType]];
    }];
    return [NSArray arrayWithArray:experienceEnhanders];
}

- (VExperienceEnhancer *)experienceEnhancerFromVoteType:(VVoteType *)voteType
{
    VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] init];
    enhancer.labelText = voteType.name;
    
    // TODO: Finish creating VExperiewnceEnhaners from VVoteTypes, figure out what to do with images
    if ( [voteType.images isKindOfClass:[NSArray class]] )
    {
        NSArray *images = (NSArray *)voteType.images;
        if ( images.count > 0 )
        {
            NSURL *url = [NSURL URLWithString:voteType.images[0]];
            enhancer.icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }
    }
   
    return enhancer;
}

- (NSArray *)createTestingExperienceEnhancers
{
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
    
    return @[ lisaEnhancer,
              tomatoEnhancer,
              fireworkEnhancer,
              thumbsUpEnhancer,
              tongueEnhancer,
              lisaEnhancer,
              tomatoEnhancer,
              lisaEnhancer,
              tomatoEnhancer ];
}

#pragma mark - Property Accessors

- (void)setEnhancerBar:(VExperienceEnhancerBar *)enhancerBar
{
    _enhancerBar = enhancerBar;
    
    enhancerBar.dataSource = self;
    enhancerBar.delegate = self;
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

#pragma mark - VExperienceEnhancerDelegate

- (void)didVoteWithExperienceEnhander:(VExperienceEnhancer *)experienceEnhancer targetPoint:(CGPoint)point
{
    // TODO: Support x & y points.  Until then:
    [self didVoteWithExperienceEnhander:experienceEnhancer];
}

- (void)didVoteWithExperienceEnhander:(VExperienceEnhancer *)experienceEnhancer
{
    VObjectManager *objectManager = [VObjectManager sharedManager];
    VVoteAction *action = [objectManager objectWithEntityName:[VVoteAction entityName] subclass:[VVoteAction class]];
    action.date = [NSDate date];
    action.sequence = self.sequence;
    [[VObjectManager sharedManager] voteSingle:action successBlock:^(NSOperation *operation, id result, NSArray *resultObjects) {
        
    } failBlock:^(NSOperation *operation, NSError *error) {
        
    }];
}

@end
