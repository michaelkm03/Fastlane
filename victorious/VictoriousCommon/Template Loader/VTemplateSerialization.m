//
//  VTemplateSerialization.m
//  victorious
//
//  Created by Josh Hinman on 4/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VTemplateSerialization.h"

@implementation VTemplateSerialization

+ (NSDictionary *)templateConfigurationDictionaryWithData:(NSData *)data
{
    NSParameterAssert( data != nil );
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ( [json isKindOfClass:[NSDictionary class]] )
    {
        return json[kVPayloadKey];
    }
    return nil;
}

@end
