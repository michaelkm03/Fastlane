//
//  VErrorMessage.m
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VErrorMessage.h"

NSString* const kVictoriousDomain = @"com.getvictorious.victoriOS";

@implementation VErrorMessage

+ (RKObjectMapping *)objectMapping
{
    
    NSDictionary *propertyMap = @{
                                  @"error" : @"errorCode",
                                  @"api_version" : @"api_version",
                                  @"app_id" : @"app_id",
                                  @"user_id" : @"user_id",
                                  @"message" : @"errorMessages",
                                  @"page_number" : @"page_number",
                                  @"total_pages" : @"total_pages"
                                  };
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[VErrorMessage class]];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    
    return mapping;
}

@end
