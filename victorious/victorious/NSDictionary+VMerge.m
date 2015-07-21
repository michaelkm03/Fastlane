//
//  NSDictionary+Merge.m
//  Pods
//
//  Created by Steven F Petteruti on 7/9/15.
//
//

#import "NSDictionary+VMerge.h"

@implementation NSDictionary (Merge)

- (NSDictionary *)v_dictionaryByMergingWithDictionary:(NSDictionary *)dictionary
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
    
    for (id key in dictionary)
    {
        id obj = [dictionary objectForKey:key];
        [melf setObject:obj forKey:key];
    }
    
    for (id key in self)
    {
        id object = [self objectForKey:key];
        [melf setObject:object forKey:key];
    }
    
    return [melf copy];
}

@end
