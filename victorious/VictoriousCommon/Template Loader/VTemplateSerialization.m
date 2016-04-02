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
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ( json != nil && [json isKindOfClass:[NSDictionary class]] )
    {
        return json[kVPayloadKey];
    }
    else
    {
        NSLog( @"Error parsing template: %@ (%@)", error.localizedDescription, error.debugDescription );
        return nil;
    }
}

@end
