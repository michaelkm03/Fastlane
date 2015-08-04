//
//  VShowPreviousCommentsAttributes.h
//  victorious
//
//  Created by Sharif Ahmed on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

/**
    A model representing the attributes that will style the in stream "see more" cell
 */
@interface VInStreamCommentsShowMoreAttributes : NSObject

/**
    Creates and returns a new VInStreamCommentsShowMoreAttributes based on the provided fields.
 */
- (instancetype)initWithUnselectedTextAttributes:(NSDictionary *)unselectedAttributes
                          selectedTextAttributes:(NSDictionary *)selectedAttributes;

/**
    A convenience method for creating a new VInStreamCommentsShowMoreAttributes object from a dependency manager.
 
    @param dependencyManager The dependency manager that should be used to generate a new VInStreamCommentsShowMoreAttributes object.
 
    @return A new VInStreamCommentsShowMoreAttributes object.
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSDictionary *unselectedTextAttributes; ///< The text attributes when the text is not highlighted
@property (nonatomic, readonly) NSDictionary *selectedTextAttributes; ///< The text attributes when the text is highlighted

@end
