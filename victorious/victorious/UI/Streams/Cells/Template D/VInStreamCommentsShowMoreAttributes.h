//
//  VShowPreviousCommentsAttributes.h
//  victorious
//
//  Created by Sharif Ahmed on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VInStreamCommentsShowMoreAttributes : NSObject

- (instancetype)initWithUnselectedTextAttributes:(NSDictionary *)unselectedAttributes
                          selectedTextAttributes:(NSDictionary *)selectedAttributes;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSDictionary *unselectedTextAttributes;
@property (nonatomic, readonly) NSDictionary *selectedTextAttributes;

@end
