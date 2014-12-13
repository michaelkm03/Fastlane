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
#import "VVoteType+Fetcher.h"
#import "VVoteResult.h"
#import "VTracking.h"
#import "VPurchaseManager.h"

@interface VExperienceEnhancerController ()

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong, readwrite) VSequence *sequence;
@property (nonatomic, strong) NSArray *experienceEnhancers;
@property (nonatomic, strong) NSArray *validExperienceEnhancers;
@property (nonatomic, strong) NSMutableArray *collectedTrackingItems;
@property (nonatomic, strong) VPurchaseManager *purchaseManager;

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
        
        NSArray *voteTypes = [VSettingManager sharedManager].voteSettings.voteTypes;
        
        self.purchaseManager = [VPurchaseManager sharedInstance];
        
        // Start saving images to disk if not already downloaded
        [self.fileCache cacheImagesForVoteTypes:voteTypes];
        
        self.experienceEnhancers = [self createExperienceEnhancersFromVoteTypes:voteTypes sequence:self.sequence];
        self.validExperienceEnhancers = self.experienceEnhancers;
        
        // Pre-load any purchaseable products that might not have already been cached
        // This is also called from VSettingsManager during app initialization, so ideally
        // most of the purchaseable products are already fetched from the App Store.
        // If not, we'll cache them now.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateData)
                                                     name:VPurchaseManagerProductsDidUpdateNotification
                                                   object:nil];
        NSSet *productIdentifiers = [VVoteType productIdentifiersFromVoteTypes:voteTypes];
        
        if ( !self.purchaseManager.isPurchaseRequestActive )
        {
            [self.purchaseManager fetchProductsWithIdentifiers:productIdentifiers success:nil failure:nil];
        }
        
        [self.enhancerBar reloadData];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                  // This effectively marks it as invalid and it will not display
                  // until the required images are loaded
                  enhancer.iconImage = nil;
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
    // The setter will re-filter accordingly
    self.validExperienceEnhancers = self.experienceEnhancers;
    
    [self updateExperience:self.validExperienceEnhancers withSequence:self.sequence];
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
    newValue = [self experienceEnhancersFilteredByCanBeUnlockedWithPurchase:newValue];
    newValue = [VExperienceEnhancer experienceEnhancersSortedByDisplayOrder:newValue];
    _validExperienceEnhancers = newValue;
}

- (NSArray *)experienceEnhancersFilteredByCanBeUnlockedWithPurchase:(NSArray *)experienceEnhancers
{
    VPurchaseManager *purchaseManager = [VPurchaseManager sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VExperienceEnhancer *enhancer, NSDictionary *bindings)
    {
        NSString *productIdentifier = enhancer.voteType.productIdentifier;
        if ( productIdentifier != nil )
        {
            enhancer.isLocked = ![purchaseManager isProductIdentifierPurchased:productIdentifier];
            
            // If there's an error of any kind that has led to the product not being present in purchase manager,
            // we should not even show the enhancer because it will be locked and will fail when the user tries to purchase it.
            // There is frequent call to fetchProducts (every time VExperienceEnhancerViewController is initialized)
            // so we don't have to worry here about re-fetching.
            return [purchaseManager purchaseableProductForProductIdentifier:productIdentifier] != nil;
        }
        return YES;
    }];
    return [experienceEnhancers filteredArrayUsingPredicate:predicate];
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
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidVoteSequence parameters:params];
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
