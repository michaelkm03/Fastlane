//
//  NSManagedObject+Validation.m
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "NSManagedObject+Validation.h"

@implementation NSManagedObject (Validation)

// TODO: 1005 == RKMappingErrorValidationFailure
// Clarification waiting on https://github.com/RestKit/RestKit/issues/1713

- (BOOL)validateValueIsGreaterThanZero:(id *)ioValue error:(NSError **)outError {
    if ([(NSNumber *)*ioValue integerValue] <= 0) {
        *outError = [NSError errorWithDomain:RKErrorDomain code:1005 userInfo:nil];
        return NO;
    }

    return YES;
}

- (BOOL)validateValueIsNotEmpty:(id *)ioValue error:(NSError **)outError {
    NSUInteger length = 0;
    if ([*ioValue respondsToSelector:@selector(length)]) {
        length = (NSInteger)[*ioValue performSelector:@selector(length)];
    }

    if (length <= 0) {
        *outError = [NSError errorWithDomain:RKErrorDomain code:1005 userInfo:nil];
        return NO;
    }

    return YES;
}

- (BOOL)validateValueIsDate:(id *)ioValue error:(NSError **)outError {
    if (![*ioValue isKindOfClass:[NSDate class]]) {
        *outError = [NSError errorWithDomain:RKErrorDomain code:1005 userInfo:nil];
        return NO;
    }

    return YES;
}

@end
