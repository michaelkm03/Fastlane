//
//  User+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VUser+RestKit.h"
#import "NSManagedObject+Validation.h"

@implementation VUser (RestKit)

+ (NSString *)entityName
{
    return @"User";
}

#pragma mark - RestKit

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                          @"access_level" : @"access_level",
                                          @"email" : @"email",
                                          @"id" : @"id",
                                          @"name" : @"name",
                                          @"token" : @"token",
                                          @"token_updated_at" : @"token_updated_at"
                                          };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                        mappingForEntityForName:[self entityName]
                                        inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:nil
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

#pragma mark - Validation

- (BOOL)validateAccess_level:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsNotEmpty:ioValue error:outError];
}

- (BOOL)validateEmail:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsNotEmpty:ioValue error:outError];
}

- (BOOL)validateId:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsGreaterThanZero:ioValue error:outError];
}

- (BOOL)validateName:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsNotEmpty:ioValue error:outError];
}

- (BOOL)validateToken:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsNotEmpty:ioValue error:outError];
}

- (BOOL)validateToken_updated_at:(id *)ioValue error:(NSError **)outError {
    return [self validateValueIsDate:ioValue error:outError];
}

@end