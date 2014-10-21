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
#import "VSettingManager.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Private.h"
#import "UIImageView+AFNetworking.h"
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VTrackingManager.h"

static const NSTimeInterval kDefaultExperienceEnhancerAnimationDuration = 0.75f;

@interface VExperienceEnhancerController ()

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VTrackingManager *trackingManager;
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
        
        self.trackingManager = [[VTrackingManager alloc] init];
        
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
        BOOL areSpriteImagesCached = [self.fileCache areSpriteImagesCachedForVoteType:voteType];
        BOOL isIconImageCached = [self.fileCache isImageCached:VVoteTypeIconName forVoteType:voteType];
        if ( !isIconImageCached || !areSpriteImagesCached )
        {
            // Start an asychronous task in the background to download missing images
            // If the images can download successfully, i.e. there is no other legitimate network error,
            // they will be available next time the content view is presented
            [self.fileCache cacheImagesForVoteType:voteType];
        }
        else
        {
            VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] initWithVoteType:voteType];
            [self.fileCache getSpriteImagesForVoteType:voteType completionCallback:^(NSArray *images) {
                enhancer.animationSequence = images;
                enhancer.flightImage = enhancer.animationSequence.firstObject;
            }];
            [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:voteType completionCallback:^(UIImage *iconImage) {
                enhancer.iconImage = iconImage;
            }];
            [experienceEnhanders addObject:enhancer];
        }
    }];
    return [NSArray arrayWithArray:experienceEnhanders];
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
    NSDictionary *params = @{ kTrackingKeyBallisticsCount : @(1),
                              kTrackingKeySequenceId : self.sequence.remoteId
                              };
    [self.trackingManager trackEventWithUrls:experienceEnhancer.voteType.tracking.ballisticCount andParameters:params];
}

@end
