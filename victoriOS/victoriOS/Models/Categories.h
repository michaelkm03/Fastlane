//
//  Categories.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VCategory;

@interface Categories : NSManagedObject

@property (nonatomic, retain) NSSet *categories;
@end

@interface Categories (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(VCategory *)value;
- (void)removeCategoriesObject:(VCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
