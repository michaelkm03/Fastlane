//
//  VTagDictionary.m
//  victorious
//
//  Created by Sharif Ahmed on 2/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagDictionary.h"
#import "VTag.h"

@interface VTrackedTag : NSObject

+ (instancetype)trackedTagWithTag:(VTag *)tag;

@property (nonatomic) VTag *tag;
@property (nonatomic) NSUInteger numberOfOccurrences;

@end

@implementation VTrackedTag

+ (instancetype)trackedTagWithTag:(VTag *)tag
{
    VTrackedTag *trackedTag = [[VTrackedTag alloc] init];
    trackedTag.tag = tag;
    trackedTag.numberOfOccurrences = 1;
    return trackedTag;
}

@end

@interface VTagDictionary ()

@property (nonatomic) NSMutableDictionary *tagDictionary;

@end

@implementation VTagDictionary

//Generate a new tagDictionary from the provided array of tags
+ (instancetype)tagDictionaryWithTags:(NSArray *)tags
{
    VTagDictionary *dictionary = [[VTagDictionary alloc] init];
    if (dictionary)
    {
        for (VTag *tag in tags)
        {
            [dictionary incrementTag:tag];
        }
    }
    return dictionary;
}

//Add or update the number of occurrences of a tag in the tagDictionary
- (void)incrementTag:(VTag *)tag
{
    if ( tag == nil )
    {
        return;
    }
    
    NSString *key = [VTagDictionary keyForTag:tag];
    VTrackedTag *trackedTag = [self.tagDictionary objectForKey:key];
    if ( trackedTag != nil )
    {
        trackedTag.numberOfOccurrences++;
    }
    else
    {
        [self.tagDictionary setObject:[VTrackedTag trackedTagWithTag:tag] forKey:key];
    }
}

//Decrement the number of occurrences or delete a tag in the tagDictionary
- (void)decrementTagWithKey:(NSString *)key
{
    if ( key == nil )
    {
        return;
    }
    
    VTrackedTag *existingTag = [self.tagDictionary objectForKey:key];
    existingTag.numberOfOccurrences--;
    if ( existingTag.numberOfOccurrences == 0 )
    {
        [self.tagDictionary removeObjectForKey:key];
    }
}

//All of the tags in the tagDictionary represented in an array. Only one of each tag, regardless of it's number of occurrences in the tagDictionary, will be returned. Will return nil if no tags are stored in the dictionary
- (NSArray *)tags
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for ( VTrackedTag *tt in self.tagDictionary.allValues )
    {
        [tags addObject:tt.tag];
    }
    return tags.count > 0 ? tags : nil;
}

//Get the tag corresponding to a given key
- (VTag *)tagForKey:(NSString *)key
{
    return [(VTrackedTag *)[self.tagDictionary objectForKey:key] tag];
}

//The key corresponding to the provided tag
+ (NSString *)keyForTag:(VTag *)tag
{
    return tag.displayString.string;
}

//The count of items in the tagDictionary
- (NSUInteger)count
{
    return self.tagDictionary.count;
}

//Lazy internal dictionary init
- (NSMutableDictionary *)tagDictionary
{
    if (_tagDictionary)
    {
        return _tagDictionary;
    }
    
    _tagDictionary = [[NSMutableDictionary alloc] init];
    return _tagDictionary;
}

//Convenience isEqual to make same tagDictionaries with same tags return true
- (BOOL)isEqual:(id)object
{
    if ( [object isKindOfClass:[self class]] )
    {
        return NO;
    }
    
    VTagDictionary *compare = object;
    
    return [self.tagDictionary isEqualToDictionary:compare.tagDictionary];
}

@end
