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

static const NSTimeInterval kDefaultExperienceEnhancerAnimationDuration = 0.75f;

@interface VExperienceEnhancerController ()

@property (nonatomic, strong) VFileCache *fileCache;

@property (nonatomic, strong, readwrite) VSequence *sequence;

@property (nonatomic, strong) NSArray *experienceEnhancers;

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
        
        NSArray *voteTypes = [[VSettingManager sharedManager] voteTypes];
        self.experienceEnhancers = [self createExperienceEnhancersFromVoteTypes:voteTypes];
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
    __block VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] init];
    enhancer.labelText = voteType.name;
    enhancer.flightDuration = voteType.flightDuration.floatValue;
    enhancer.animationDuration = voteType.animationDuration.floatValue;
    
    BOOL areSpriteImagesCached = [self.fileCache areSpriteImagesCachedForVoteType:voteType];
    if ( areSpriteImagesCached )
    {
        [self.fileCache getSpriteImagesForVoteType:voteType completionCallback:^(NSArray *images) {
            enhancer.animationSequence = images;
            enhancer.flightImage = enhancer.animationSequence.firstObject;
            enhancer.ballistic = enhancer.flightImage != nil && voteType.flightDuration.floatValue > 0.0;
        }];
    }
    
    BOOL isIconImageCached = [self.fileCache isImageCached:VVoteTypeIconName forVoteType:voteType];
    if ( isIconImageCached )
    {
        [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:voteType completionCallback:^(UIImage *iconImage) {
            enhancer.iconImage = iconImage;
        }];
    }
    
    if ( !isIconImageCached || !areSpriteImagesCached )
    {
        // Start an asychronous task in the background to download missing images
        // If the images can download successfully, i.e. there is no other legitimate network error,
        // they will be available next time the content view is presented
        [self.fileCache cacheImagesForVoteType:voteType];
        
        return nil;
    }
    
    return enhancer;
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
    return (NSInteger)self.experienceEnhancers.count;
}

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index
{
    return [self.experienceEnhancers objectAtIndex:(NSUInteger)index];
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
