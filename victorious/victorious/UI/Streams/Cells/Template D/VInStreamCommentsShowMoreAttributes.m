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
    NSParameterAssert(unselectedAttributes != nil);
    NSParameterAssert(selectedAttributes != nil);
    
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
    
    NSMutableDictionary *unselectedAttributes = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *selectedAttributes = [[NSMutableDictionary alloc] init];
    if ( font != nil )
    {
        [unselectedAttributes setObject:font forKey:NSFontAttributeName];
        [selectedAttributes setObject:font forKey:NSFontAttributeName];
    }
    
    if ( unselectedColor != nil )
    {
        [unselectedAttributes setObject:unselectedColor forKey:NSForegroundColorAttributeName];
    }
    
    if ( selectedColor != nil )
    {
        [selectedAttributes setObject:selectedColor forKey:NSForegroundColorAttributeName];
    }
    
    return [[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:[unselectedAttributes copy]
                                                              selectedTextAttributes:[selectedAttributes copy]];
}

@end
