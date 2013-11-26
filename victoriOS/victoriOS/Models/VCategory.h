//
//  VCategory.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categories;

@interface VCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Categories *categories;

@end
