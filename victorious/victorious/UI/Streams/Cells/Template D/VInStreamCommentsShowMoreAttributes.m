//
//  VShowPreviousCommentsAttributes.m
//  victorious
//
//  Created by Sharif Ahmed on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsShowMoreAttributes.h"
#import "VDependencyManager.h"

@implementation VInStreamCommentsShowMoreAttributes

- (instancetype)initWithUnselectedTextAttributes:(NSDictionary *)unselectedAttributes
                          selectedTextAttributes:(NSDictionary *)selectedAttributes
{
    self = [super init];
    if ( self != nil )
    {
        _unselectedTextAttributes = unselectedAttributes;
        _selectedTextAttributes = selectedAttributes;
    }
    return self;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(dependencyManager != nil);
    
    UIColor *unselectedColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    UIColor *selectedColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    UIFont *font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    
    NSDictionary *unselectedAttributes = @{ NSForegroundColorAttributeName : unselectedColor, NSFontAttributeName : font };
    NSDictionary *selectedAttributes = @{ NSForegroundColorAttributeName : selectedColor, NSFontAttributeName : font };
    
    return [[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:unselectedAttributes
                                                              selectedTextAttributes:selectedAttributes];
}

@end
