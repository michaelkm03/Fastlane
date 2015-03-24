//
//  NSDictionary+VJSONLogging.m
//  victorious
//
//  Created by Sharif Ahmed on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSDictionary+VJSONLogging.h"

@implementation NSDictionary (VJSONLogging)

- (void)logJSONStringWithTitle:(NSString *)title
{
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&jsonError];
    if ( jsonData == nil )
    {
        NSLog( @"Unable to print template JSON data: %@", [jsonError localizedDescription] );
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog( @"\n\n***** %@ *****\n%@\n\n", title, jsonString );
}

@end
