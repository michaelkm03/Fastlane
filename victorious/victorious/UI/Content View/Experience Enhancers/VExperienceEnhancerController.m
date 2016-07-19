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
#import "VVoteType.h"
#import "VVoteResult.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"

@interface VExperienceEnhancerController ()

@property (nonatomic, strong, readwrite) VSequence *sequence;
@property (nonatomic, strong) NSArray *experienceEnhancers;
@property (nonatomic, strong) NSMutableArray *collectedTrackingItems;
@property (nonatomic, assign) id<VPurchaseManagerType> purchaseManager;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VExperienceEnhancerController

@synthesize experienceEnhancers = _experienceEnhancers;

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

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                          purchaseManager:(id<VPurchaseManagerType>)purchaseManager
{
    self = [super init];
    if ( self != nil )
    {
        _purchaseManager = purchaseManager;
        _dependencyManager = dependencyManager;
        
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    // Pre-load any purchaseable products that might not have already been cached
    // This is also called from VSettingsManager during app initialization, so ideally
    // most of the purchaseable products are already fetched from the App Store.
    // If not, we'll cache them now.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchaseManagedDidUpdate:)
                                                 name:VPurchaseManagerProductsDidUpdateNotification
                                               object:nil];
    
    self.sequence = [self.dependencyManager templateValueOfType:[VSequence class] forKey:@"sequence"];
    /// Body removed alongside FetchTemplateProductIdentifiersOperation
}

- (void)onExperienceEnhancersLoaded:(NSArray *)experienceEnhancers
{
    self.experienceEnhancers = [self validExperienceEnhancers:experienceEnhancers];
    [self.enhancerBar reloadData];
    [self.delegate experienceEnhancersDidUpdate];
    
    // Removed Ballistics notification scheduler
}

- (void)purchaseManagedDidUpdate:(NSNotification *)notification
{
    self.experienceEnhancers = [self validExperienceEnhancers:self.experienceEnhancers];
    [self updateData];
}

- (void)updateData
{
    if ( self.sequence.voteResults == nil || self.sequence.voteResults.count == 0 || self.experienceEnhancers.count == 0 )
    {
        return;
    }
    
    [self.sequence.voteResults enumerateObjectsUsingBlock:^(VVoteResult *result, BOOL *sequenceLoopStop)
     {
         [self.experienceEnhancers enumerateObjectsUsingBlock:^(VExperienceEnhancer *enhancer, NSUInteger idx, BOOL *enhancerLoopStop)
          {
              if ( enhancer.voteType.voteTypeID.integerValue == result.remoteId.integerValue )
              {
                  enhancer.voteCount = result.count.integerValue;
                  *enhancerLoopStop = YES;
              }
          }];
     }];
    self.experienceEnhancers = [self validExperienceEnhancers:self.experienceEnhancers];
    [self.enhancerBar reloadData];
    [self.delegate experienceEnhancersDidUpdate];
}

- (NSArray *)validExperienceEnhancers:(NSArray *)experientEnhancers
{
    NSArray *newValue = experientEnhancers;
    newValue = [VExperienceEnhancer experienceEnhancersFilteredByHasRequiredImages:newValue];
    newValue = [self experienceEnhancersFilteredByCanBeUnlockedWithPurchase:newValue];
    newValue = [VExperienceEnhancer experienceEnhancersSortedByDisplayOrder:newValue];
    return newValue;
}

- (NSArray *)experienceEnhancersFilteredByCanBeUnlockedWithPurchase:(NSArray *)experienceEnhancers
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VExperienceEnhancer *enhancer, NSDictionary *bindings)
    {
        NSString *productIdentifier = enhancer.voteType.productIdentifier;
        if ( productIdentifier != nil )
        {
            enhancer.requiresPurchase = ![self.purchaseManager isProductIdentifierPurchased:productIdentifier];
            
            // If there's an error of any kind that has led to the product not being present in purchase manager,
            // we should not even show the enhancer because it will be locked and will fail when the user tries to purchase it.
            // There is frequent call to fetchProducts (every time VExperienceEnhancerViewController is initialized)
            // so we don't have to worry here about re-fetching.
            return [self.purchaseManager purchaseableProductForProductIdentifier:productIdentifier] != nil;
        }
        return YES;
    }];
    return [experienceEnhancers filteredArrayUsingPredicate:predicate];
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
    return (NSInteger) self.experienceEnhancers.count;
}

- (VExperienceEnhancer *)experienceEnhancerForIndex:(NSInteger)index
{
    return [self.experienceEnhancers objectAtIndex:(NSUInteger)index];
}

#pragma mark - VExperienceEnhancerBarDelegate

- (void)experienceEnhancerSelected:(VExperienceEnhancer *)enhancer
{
    NSDictionary *sharedParams = @{ VTrackingKeyVoteCount : @( 1 ),
                                    VTrackingKeySequenceId : self.sequence.remoteId,
                                    VTrackingKeyUrls : enhancer.trackingUrls };
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:sharedParams];
    
    if ( self.delegate.isVideoContent )
    {
        Float64 currentVideoTime = self.delegate.currentVideoTime;
        [params addEntriesFromDictionary:@{ VTrackingKeyTimeCurrent : @( currentVideoTime ) }];
    }
    
    NSDictionary *finalParams = [NSDictionary dictionaryWithDictionary:params];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidVoteSequence parameters:finalParams];

    // Removed Ballistics notification scheduler
}

- (VExperienceEnhancer *)lastExperienceEnhancerToCoolDown
{
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(VExperienceEnhancer *experienceEnhancer, NSDictionary *bindings)
                                    {
                                        return experienceEnhancer.cooldownDate != nil;
                                    }];
    NSArray *filtered = [self.experienceEnhancers filteredArrayUsingPredicate:filterPredicate];
    NSArray *sorted = [filtered sortedArrayUsingComparator:^NSComparisonResult( VExperienceEnhancer *a, VExperienceEnhancer *b)
                       {
                           return [b.cooldownDate compare:a.cooldownDate];
                       }];
    VExperienceEnhancer *experienceEnhancer = sorted.firstObject;
    if ( experienceEnhancer.cooldownDuration > 0.0 )
    {
        return experienceEnhancer;
    }
    return nil;
}

@end
