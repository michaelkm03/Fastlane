//
//  VLayoutComponent.h
//  victorious
//
//  Created by Patrick Lynch on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VSequence;

typedef CGSize(^VLayoutComponentDynamicSize)(CGSize, VSequence *, VDependencyManager *);

@interface VLayoutComponent : NSObject

- (instancetype)initWithConstantSize:(CGSize)constantSize dynamicSize:(VLayoutComponentDynamicSize)dynamicSize;

@property (nonatomic, assign, readonly) CGSize constantSize;

@property (nonatomic, copy, readonly) VLayoutComponentDynamicSize dynamicSize;

@end

@interface VLayoutComponentCollection : NSObject

- (void)addComponentWithConstantSize:(CGSize)constantSize;

- (void)addComponentWithDynamicSize:(VLayoutComponentDynamicSize)dynamicSize;

- (void)addComponentWithComponentWithConstantSize:(CGSize)constantSize dynamicSize:(VLayoutComponentDynamicSize)dynamicSize;

- (CGSize)totalSizeWithBaseSize:(CGSize)base sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager;

@end