//
//  NSManagedObject+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//


@interface NSManagedObject (RestKit)

+ (NSString *)entityName;
+ (RKEntityMapping*)entityMapping;

@end
