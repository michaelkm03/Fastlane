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
#import "VVoteType.h"
#import "VVoteResult.h"
#import "VTracking.h"

@interface VExperienceEnhancerController ()

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong, readwrite) VSequence *sequence;
@property (nonatomic, strong) NSArray *experienceEnhancers;
@property (nonatomic, strong) NSArray *validExperienceEnhancers;
@property (nonatomic, strong) NSMutableArray *collectedTrackingItems;

@end

@implementation VExperienceEnhancerController

#pragma mark - Initialization

+ (NSCache *)imageMemoryCache
{
    static dispatch_once_t onceToken;
    static NSCache *cache;
    dispatch_once(&onceToken, ^(void)
                  {
                      cache = [[NSCache alloc] init];
                  });
    
    return cache;
}

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        self.sequence = sequence;
        
        self.fileCache = [[VFileCache alloc] init];
        
        NSArray *voteTypes = [[VSettingManager sharedManager] voteTypes];
        
        // Start saving images to disk if not already downloaded
        [self.fileCache cacheImagesForVoteTypes:voteTypes];
        
        self.experienceEnhancers = [self createExperienceEnhancersFromVoteTypes:voteTypes sequence:self.sequence];
        self.validExperienceEnhancers = self.experienceEnhancers;
        
        [self.enhancerBar reloadData];
    }
    return self;
}

- (NSArray *)createExperienceEnhancersFromVoteTypes:(NSArray *)voteTypes sequence:(VSequence *)sequence
{
    NSMutableArray *experienceEnhanders = [[NSMutableArray alloc] init];
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         VVoteResult *result = [self resultForVoteType:voteType fromSequence:sequence];
         NSUInteger existingVoteCount = result.count.unsignedIntegerValue;
         VExperienceEnhancer *enhancer = [[VExperienceEnhancer alloc] initWithVoteType:voteType voteCount:existingVoteCount];
         
         // Get animation sequence files asynchronously
         [self.fileCache getSpriteImagesForVoteType:voteType completionCallback:^(NSArray *images)
          {
              if ( images == nil || images.count == 0 )
              {
                  enhancer.iconImage = nil; // This effectively marks it as invalid and it will not display
              }
              else
              {
                  enhancer.animationSequence = images;
                  enhancer.flightImage = images.firstObject;
              }
              
          }];
         
         // Get icon image synhronously (we need it right away)
         NSCache *imageMemoryCache = [VExperienceEnhancerController imageMemoryCache];
         NSString *key = [self.fileCache savePathForImage:VVoteTypeIconName forVote:voteType];
         if ( [imageMemoryCache objectForKey:key] )
         {
             enhancer.iconImage = [imageMemoryCache objectForKey:key];
         }
         else
         {
             enhancer.iconImage = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:voteType];
             if ( enhancer.iconImage != nil )
             {
                 [imageMemoryCache setObject:enhancer.iconImage forKey:key];
             }
         }
         
         [experienceEnhanders addObject:enhancer];
    }];
    
    return [NSArray arrayWithArray:experienceEnhanders];
}

- (void)updateData
{
    [self updateExperience:self.experienceEnhancers withSequence:self.sequence];
    [self.enhancerBar reloadData];
}

- (BOOL)updateExperience:(NSArray *)experienceEnhancers withSequence:(VSequence *)sequence
{
    if ( sequence.voteResults == nil || sequence.voteResults.count == 0 || experienceEnhancers.count == 0 )
    {
        return NO;
    }
    
    [sequence.voteResults enumerateObjectsUsingBlock:^(VVoteResult *result, BOOL *stop)
     {
         [experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *enhancer, NSUInteger idx, BOOL *stop)
          {
              if ( enhancer.voteType.remoteId.integerValue == result.remoteId.integerValue )
              {
                  [enhancer resetStartingVoteCount:result.count.integerValue];
              }
          }];
     }];
    
    return YES;
}

- (VVoteResult *)resultForVoteType:(VVoteType *)voteType fromSequence:(VSequence *)sequence
{
    __block VVoteResult *outputResult = nil;
    [sequence.voteResults enumerateObjectsUsingBlock:^(VVoteResult *result, BOOL *stop)
     {
         if ( [result.remoteId isEqual:voteType.remoteId] )
         {
             outputResult = result;
             *stop = YES;
         }
     }];
    return outputResult;
}

- (void)setValidExperienceEnhancers:(NSArray *)validExperienceEnhancers
{
    NSArray *newValue = validExperienceEnhancers;
    newValue = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:newValue];
    newValue = [VExperienceEnhancer experienceEnhancersSortedByDisplayOrder:newValue];
    _validExperienceEnhancers = newValue;
}

- (void)sendTrackingEvents
{
    [self.experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *enhancer, NSUInteger idx, BOOL *stop)
    {
        NSUInteger voteCount = enhancer.sessionVoteCount;
        if ( voteCount > 0 )
        {
            NSDictionary *params = @{ VTrackingKeyVoteCount : @( voteCount ),
                                      VTrackingKeySequenceId : self.sequence.remoteId,
                                      VTrackingKeyUrls : enhancer.voteType.tracking.ballisticCount };
            [[VTrackingManager sharedInstance] trackEvent:nil withParameters:params];
            [enhancer resetSessionVoteCount];
        }
    }];
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
    return (NSInteger) self.validExperienceEnhancers.count;
}

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index
{
    return [self.validExperienceEnhancers objectAtIndex:(NSUInteger)index];
}

@end
