//
//  VTextPostCallout.m
//  victorious
//
//  Created by Patrick Lynch on 5/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostCalloutHelper.h"
#import "VHashtags.h"
#import "VURLDetector.h"

@implementation VTextPostCallout

- (instancetype)initWithText:(NSString *)text range:(NSRange)range type:(VTextCalloutType)type
{
    self = [super init];
    if ( self != nil )
    {
        _text = text;
        _range = range;
        _type = type;
    }
    return self;
}

@end

@implementation VTextPostCalloutHelper

+ (NSCache *)calloutRangesCache
{
    static NSCache *calloutRangesCache;
    if ( calloutRangesCache == nil )
    {
        calloutRangesCache = [[NSCache alloc] init];
    }
    return calloutRangesCache;
}

- (NSDictionary *)calloutsForText:(NSString *)text
{
    NSCache *cache = [[self class] calloutRangesCache];
    NSDictionary *callouts = [cache objectForKey:text];
    if ( callouts == nil )
    {
        NSMutableDictionary *mutableCallouts = [[NSMutableDictionary alloc] init];
        
        // Add hashtags
        NSArray *hashtagRanges = [VHashTags detectHashTags:text includeHashSymbol:YES];
        for ( NSValue *value in hashtagRanges )
        {
            NSRange range = value.rangeValue;
            NSString *calloutText = [text substringWithRange:range];
            if ( calloutText != nil && calloutText.length > 0 )
            {
                mutableCallouts[ calloutText ] = [[VTextPostCallout alloc] initWithText:calloutText range:range type:VTextCalloutTypeHashtag];
            }
        }
        
        // Add URLs
        VURLDetector *urlDetector = [[VURLDetector alloc] init];
        NSArray *urlRanges = [urlDetector detectFromString:text];
        for ( NSValue *value in urlRanges )
        {
            NSRange range = value.rangeValue;
            NSString *calloutText = [text substringWithRange:range];
            if ( calloutText != nil && calloutText.length > 0 )
            {
                mutableCallouts[ calloutText ] = [[VTextPostCallout alloc] initWithText:calloutText range:range type:VTextCalloutTypeURL];
            }
        }
        
        callouts = [mutableCallouts copy];
        [cache setObject:callouts forKey:text];
    }
    return callouts;
}

- (NSArray *)calloutRangesForText:(NSString *)text
{
    NSDictionary *callouts = [self calloutsForText:text];
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    for ( NSString *key in callouts )
    {
        VTextPostCallout *callout = callouts[ key ];
        NSValue *value = [NSValue valueWithRange:callout.range];
        [ranges addObject:value];
    }
    return [ranges copy];
}

@end
