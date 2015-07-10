//
//  NSDictionary+Merge.m
//  Pods
//
//  Created by Steven F Petteruti on 7/9/15.
//
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary
{
    if (self == nil)
    {
        return dictionary;
    }
    if (dictionary == nil)
    {
        return self;
    }
    NSMutableDictionary *melf = [self mutableCopy];
    
    for (id key in [dictionary allKeys])
    {
        id obj = [dictionary objectForKey:key];
        [melf setObject:obj forKey:key];
        
    }
    
    for (id key in [self allKeys])
    {
        id object = [self objectForKey:key];
        [melf setObject:object forKey:key];
    }
    
    return [melf copy];
}

@end
