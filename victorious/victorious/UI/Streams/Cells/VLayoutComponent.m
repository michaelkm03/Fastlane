//
//  VLayoutComponent.m
//  victorious
//
//  Created by Patrick Lynch on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLayoutComponent.h"

@interface VLayoutComponent()

@property (nonatomic, assign, readwrite) CGSize constantSize;

@property (nonatomic, copy, readwrite) VLayoutComponentDynamicSize dynamicSize;

@end

@implementation VLayoutComponent

- (instancetype)initWithConstantSize:(CGSize)constantSize dynamicSize:(VLayoutComponentDynamicSize)dynamicSize
{
    self = [super init];
    if ( self != nil )
    {
        self.constantSize = constantSize;
        self.dynamicSize = dynamicSize;
    }
    return self;
}

@end


@interface VLayoutComponentCollection ()

@property (nonatomic, strong) NSMutableArray *layoutComponents;

@end

@implementation VLayoutComponentCollection

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _layoutComponents = [[NSMutableArray alloc] init];
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

- (CGSize)totalSizeWithBaseSize:(CGSize)base sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize total = base;
    
    for ( VLayoutComponent *component in self.layoutComponents )
    {
        if ( component.dynamicSize != nil )
        {
            CGSize size = component.dynamicSize( base, sequence, dependencyManager );
            total.width += size.width;
            total.height += size.height;
        }
        
        total.width += component.constantSize.width;
        total.height += component.constantSize.height;
    }
    
    return total;
}

@end