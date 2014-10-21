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
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"

/**
 This will switch between (0) using hardcoded experience enhancers that demonstrate
 the full range of animation capabilities and (1) using only the experience enhancers
 enabled by the server in its response to /api/init and the data each contains.
 */
// TODO: Remove this
#define USE_INIT_SETTINGS 1

static const NSTimeInterval kDefaultExperienceEnhancerAnimationDuration = 0.75f;

@interface VExperienceEnhancerController ()

@property (nonatomic, strong) VFileCache *fileCache;

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong) NSArray *testEnhancers;

@end

@implementation VExperienceEnhancerController

#pragma mark - Initialization

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        self.sequence = sequence;
        
        self.fileCache = [[VFileCache alloc] init];
        
#if USE_INIT_SETTINGS
        NSArray *voteTypes = [[VSettingManager sharedManager] voteTypes];
        self.testEnhancers = [self createExperienceEnhancersFromVoteTypes:voteTypes];
#else
        self.testEnhancers = [VExperienceEnhancerController experuebce:sequence];
#endif
    }
    return self;
}

- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes
{
    NSMutableArray *experienceEnhanders = [[NSMutableArray alloc] init];
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
    {
        VExperienceEnhancer *enhancer = [self experienceEnhancerFromVoteType:voteType];
        if ( enhancer != nil )
        {
            [experienceEnhanders addObject:enhancer];
        }
    }];
    return [NSArray arrayWithArray:experienceEnhanders];
}

- (VExperienceEnhancer *)experienceEnhancerFromVoteType:(VVoteType *)voteType
{
    VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] init];
    enhancer.labelText = voteType.name;
    enhancer.flightDuration = voteType.flightDuration.floatValue;
    enhancer.animationDuration = voteType.animationDuration.floatValue;
    
    // Load the images synchronously from disk
    enhancer.animationSequence = [self.fileCache getSpriteImagesForVoteType:voteType];
    enhancer.iconImage = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:voteType];
    
    if ( enhancer.animationSequence.count > 0 )
    {
        enhancer.flightImage = enhancer.animationSequence.firstObject;
        enhancer.ballistic = enhancer.flightImage != nil && voteType.flightDuration.floatValue > 0.0;
    }
    
    // A final check to make sure the enhancer can be displayed
    if ( enhancer.hasRequiredImages )
    {
        return enhancer;
    }
    
    // Start an asychronous task in the background to download missing images
    // If the images can download successfully, i.e. there is no other legitimate network error,
    // they will be available next time the content view is presented
    [self.fileCache cacheImagesForVoteType:voteType];
    return nil;
}

- (BOOL)validateExperienceEnhancer:(VExperienceEnhancer *)enhancer
{
    if ( enhancer.isBallistic )
    {
        return enhancer.flightImage != nil;
    }
    else
    {
        return enhancer.iconImage != nil && enhancer.animationSequence != nil && enhancer.animationSequence.count > 0;
    }
}

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
    VExperienceEnhancer *fireworkEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_firework"]
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
    VExperienceEnhancer *lolEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_lol"]
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
    VExperienceEnhancer *glitterEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_glitter"]
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
    
    VExperienceEnhancer *lightningEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_lightning"]
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
    VExperienceEnhancer *waterBaloonEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_waterballoon"]
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
    VExperienceEnhancer *lisaEnhancer = [VExperienceEnhancer experienceEnhancerWithIconImage:[UIImage imageNamed:@"eb_bacon"]
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
    [[VObjectManager sharedManager] voteSingle:action successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         
     }
                                     failBlock:^(NSOperation *operation, NSError *error)
     {
         
     }];
}

@end
