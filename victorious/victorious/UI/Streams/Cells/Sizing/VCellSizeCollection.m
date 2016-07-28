//
//  VCellSizeCollection.m
//  victorious
//
//  Created by Patrick Lynch on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCellSizeCollection.h"

NSString * const VCellSizeCacheKey = @"cacheKey";
NSString * const VCellSizingCommentsKey = @"comments";

@interface VCellSizeCollection ()

@property (nonatomic, strong) NSMutableArray *layoutComponents;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation VCellSizeCollection

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _layoutComponents = [[NSMutableArray alloc] init];
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)addComponentWithConstantSize:(CGSize)constantSize
{
    VCellSizeComponent *component = [[VCellSizeComponent alloc] initWithConstantSize:constantSize dynamicSize:nil];
    [self.layoutComponents addObject:component];
}

- (void)addComponentWithDynamicSize:(VDynamicCellSizeBlock)dynamicSize
{
    VCellSizeComponent *component = [[VCellSizeComponent alloc] initWithConstantSize:CGSizeZero dynamicSize:dynamicSize];
    [self.layoutComponents addObject:component];
}

- (void)addComponentWithComponentWithConstantSize:(CGSize)constantSize dynamicSize:(VDynamicCellSizeBlock)dynamicSize
{
    VCellSizeComponent *component = [[VCellSizeComponent alloc] initWithConstantSize:constantSize dynamicSize:dynamicSize];
    [self.layoutComponents addObject:component];
}

- (CGSize)totalSizeWithBaseSize:(CGSize)base userInfo:(NSDictionary *)userInfo
{
    CGSize total = base;
    
    id cacheKey = userInfo[ VCellSizeCacheKey ];
    
    NSDictionary *cachedInfo = (NSDictionary *)[self.cache objectForKey:cacheKey];
    BOOL commentsHaveUpdated = ![cachedInfo[VCellSizingCommentsKey] isEqualToArray:userInfo[VCellSizingCommentsKey]];
    
    NSAssert( cacheKey != nil, @"Calling code must provide a value for `%@` in the userInfo parameter", VCellSizeCacheKey );
    
    NSValue *cachedValue = (NSValue *)[cachedInfo objectForKey:VCellSizeCacheKey];
    if ( cachedValue != nil && !commentsHaveUpdated)
    {
        return cachedValue.CGSizeValue;
    }
    
    for ( VCellSizeComponent *component in self.layoutComponents )
    {
        if ( component.dynamicSize != nil )
        {
            CGSize size = component.dynamicSize( base, userInfo );
            total.width += size.width;
            total.height += size.height;
        }
        
        total.width += component.constantSize.width;
        total.height += component.constantSize.height;
    }
    
    NSDictionary *cacheValue = @{ VCellSizeCacheKey : [NSValue valueWithCGSize:total] };
    NSArray *comments = [userInfo objectForKey:VCellSizingCommentsKey];
    if ( comments != nil )
    {
        NSMutableDictionary *updatedCacheValue = [cacheValue mutableCopy];
        [updatedCacheValue addEntriesFromDictionary:@{ VCellSizingCommentsKey : comments }];
        cacheValue = [updatedCacheValue copy];
    }
    [self.cache setObject:cacheValue forKey:cacheKey];
    
    return total;
}

- (void)removeSizeCacheForItemWithCacheKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (NSArray *)commentsForCacheKey:(NSString *)key
{
    return [(NSDictionary *)[self.cache objectForKey:key] objectForKey:VCellSizingCommentsKey];
}

@end
