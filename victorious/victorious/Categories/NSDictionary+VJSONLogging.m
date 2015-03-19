//
//  NSDictionary+VJSONLogging.m
//  victorious
//
//  Created by Sharif Ahmed on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSDictionary+VJSONLogging.h"

@implementation NSDictionary (VJSONLogging)

static void VPrintTemplate( NSDictionary *templateComponent, NSString *componentTitle )
{
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:templateComponent options:NSJSONWritingPrettyPrinted error:&jsonError];
    if ( jsonData == nil )
    {
        NSLog( @"Unable to print template JSON data: %@", [jsonError localizedDescription] );
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog( @"\n\n***** %@ *****\n%@\n\n", componentTitle, jsonString );
};

- (void)logJSONStringWithTitle:(NSString *)title
{
    VPrintTemplate(self, title);
}

@end
