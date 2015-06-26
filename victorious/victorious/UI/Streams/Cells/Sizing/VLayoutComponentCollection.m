//
//  VLayoutComponentCollection.m
//  victorious
//
//  Created by Patrick Lynch on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLayoutComponentCollection.h"

NSString * const VLayoutComponentCacheKey = @"cacheKey";


@interface VLayoutComponentCollection ()

@property (nonatomic, strong) NSMutableArray *layoutComponents;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation VLayoutComponentCollection

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
    VLayoutComponent *component = [[VLayoutComponent alloc] initWithConstantSize:constantSize dynamicSize:nil];
    [self.layoutComponents addObject:component];
}

- (void)addComponentWithDynamicSize:(VLayoutComponentDynamicSize)dynamicSize
{
    VLayoutComponent *component = [[VLayoutComponent alloc] initWithConstantSize:CGSizeZero dynamicSize:dynamicSize];
    [self.layoutComponents addObject:component];
}

- (void)addComponentWithComponentWithConstantSize:(CGSize)constantSize dynamicSize:(VLayoutComponentDynamicSize)dynamicSize
{
    VLayoutComponent *component = [[VLayoutComponent alloc] initWithConstantSize:constantSize dynamicSize:dynamicSize];
    [self.layoutComponents addObject:component];
}

- (CGSize)totalSizeWithBaseSize:(CGSize)base userInfo:(NSDictionary *)userInfo
{
    CGSize total = base;
    
    id cacheKey = userInfo[ VLayoutComponentCacheKey ];
    
    NSAssert( cacheKey != nil, @"Calling code must provide a value for `%@` in the userInfo parameter", VLayoutComponentCacheKey );
    
    NSValue *cachedValue = (NSValue *)[self.cache objectForKey:cacheKey];
    if ( cachedValue != nil )
    {
        return cachedValue.CGSizeValue;
    }
    
    for ( VLayoutComponent *component in self.layoutComponents )
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
    
    [self.cache setObject:[NSValue valueWithCGSize:total] forKey:cacheKey];
    
    return total;
}

@end