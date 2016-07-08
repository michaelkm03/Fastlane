//
//  VTag.m
//  victorious
//
//  Created by Sharif Ahmed on 2/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTag.h"
#import "VUserTag.h"
#import "VHashtag.h"
#import "VTagStringFormatter.h"

@implementation VTag

#pragma mark - testing init

- (instancetype)initWithAttributedDisplayString:(NSMutableAttributedString *)displayString
                        databaseFormattedString:(NSString *)databaseFormattedString
                         andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    self = [super init];
    if ( self != nil )
    {
        _displayString = displayString;
        _tagStringAttributes = tagStringAttributes;
        _databaseFormattedString = databaseFormattedString;
    }
    return self;
}

#pragma mark - internal init

- (instancetype)initWithDisplayString:(NSString *)displayString
              databaseFormattedString:(NSString *)databaseFormattedString
               andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    if ( displayString == nil || databaseFormattedString == nil || tagStringAttributes == nil )
    {
        return nil;
    }
    
    self = [super init];
    if ( self != nil )
    {
        _displayString = [[NSMutableAttributedString alloc] initWithString:displayString];
        _tagStringAttributes = tagStringAttributes;
        [_displayString setAttributes:tagStringAttributes range:NSMakeRange(0, displayString.length)];
        _databaseFormattedString = databaseFormattedString;
    }
    return self;
}

#pragma mark - visible functions

+ (instancetype)tagWithHashtagString:(NSString *)hashtagString
              andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    //Find the location, if any, of the hashtag tag within the userString
    NSArray *matches = [[VTagStringFormatter hashtagRegex] matchesInString:hashtagString
                                                                   options:0
                                                                     range:NSMakeRange(0, hashtagString.length)];
    
    //There should only be one match
    NSTextCheckingResult *hashtagCheckResult = [matches lastObject];
    
    //result rangeAtIndex 1 has the value of the regex closure (the display string)
    return [[VTag alloc] initWithDisplayString:[hashtagString substringWithRange:[hashtagCheckResult rangeAtIndex:1]] databaseFormattedString:hashtagString andTagStringAttributes:tagStringAttributes];
}

+ (instancetype)tagWithUserString:(NSString *)userString
           andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    //Find the location, if any, of the user name within the userString
    NSArray *matches = [[VTagStringFormatter userRegex] matchesInString:userString
                                                                options:0
                                                                  range:NSMakeRange(0, userString.length)];
    
    //There should only be one match
    NSTextCheckingResult *userCheckResult = [matches lastObject];
    
    //result rangeAtIndex 1 has the value of the regex closure (the display string)
    return [[VUserTag alloc] initWithDisplayString:[userString substringWithRange:[userCheckResult rangeAtIndex:2]] databaseFormattedString:userString remoteId:@([[userString substringWithRange:[userCheckResult rangeAtIndex:1]] integerValue]) andTagStringAttributes:tagStringAttributes];
}

+ (instancetype)tagWithUser:(VUser *)user
     andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    NSAssert(user != nil, @"Must supply a user to create a tag");
    NSAssert(tagStringAttributes != nil, @"Must supply tagStringAttributes to format");
    
    return [self tagWithUserString:[VTagStringFormatter databaseFormattedStringFromUser:user] andTagStringAttributes:tagStringAttributes];
}

+ (instancetype)tagWithHashtag:(VHashtag *)hashtag
        andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    NSAssert(hashtag != nil, @"Must supply a hashtag to create a tag");
    NSAssert(tagStringAttributes != nil, @"Must supply tagStringAttributes to format");
    
    return [self tagWithHashtagString:[VTagStringFormatter databaseFormattedStringFromHashtag:hashtag] andTagStringAttributes:tagStringAttributes];
}

@end
