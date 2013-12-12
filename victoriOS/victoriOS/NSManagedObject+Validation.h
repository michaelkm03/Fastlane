//
//  NSManagedObject+Validation.h
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Validation)

- (BOOL)validateValueIsGreaterThanZero:(id *)ioValue error:(NSError **)outError;
- (BOOL)validateValueIsNotEmpty:(id *)ioValue error:(NSError **)outError;
- (BOOL)validateValueIsDate:(id *)ioValue error:(NSError **)outError;

@end
