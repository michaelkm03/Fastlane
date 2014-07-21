//
//  VPhotoFilterSerialization.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPhotoFilter.h"
#import "VPhotoFilterSerialization.h"

static NSString * const kFilterNameKey                = @"name";
static NSString * const kFilterComponentsKey          = @"components";
static NSString * const kFilterComponentNameKey       = @"name";
static NSString * const kFilterComponentInputsKey     = @"inputs";
static NSString * const kFilterComponentInputKeyKey   = @"inputKey";
static NSString * const kFilterComponentInputValueKey = @"value";

@implementation VPhotoFilterSerialization

+ (NSArray *)filtersFromPlistFile:(NSURL *)fileURL
{
    NSData *filterData = [NSData dataWithContentsOfURL:fileURL];
    if (!filterData)
    {
        return nil;
    }
    
    NSArray *filterPlist = [NSPropertyListSerialization propertyListWithData:filterData
                                                                     options:NSPropertyListImmutable
                                                                      format:nil
                                                                       error:nil];
    NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:filterPlist.count];
    for (NSDictionary *filterDefinition in filterPlist)
    {
        VPhotoFilter *filter = [[VPhotoFilter alloc] init];
        filter.name = filterDefinition[kFilterNameKey];
        NSArray *componentDefinitions = filterDefinition[kFilterComponentsKey];
        NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:componentDefinitions.count];
        for (NSDictionary *componentDefinition in componentDefinitions)
        {
            NSString *componentName = componentDefinition[kFilterComponentNameKey];
            CIFilter *component = [CIFilter filterWithName:componentName];
            if (component)
            {
                NSArray *inputs = componentDefinition[kFilterComponentInputsKey];
                for (NSDictionary *inputDefinition in inputs)
                {
                    NSString *inputKey = inputDefinition[kFilterComponentInputKeyKey];
                    NSNumber *inputValue = inputDefinition[kFilterComponentInputValueKey];
                    [component setValue:inputValue forKey:inputKey];
                }
                [components addObject:component];
            }
        }
        filter.components = components;
        [retVal addObject:filter];
    }
    return retVal;
}

@end
