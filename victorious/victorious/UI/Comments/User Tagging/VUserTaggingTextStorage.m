//
//  VUserTaggingTextStorage.m
//  victorious
//
//  Created by Josh Hinman on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserTaggingTextStorage.h"

typedef NS_ENUM(NSInteger, VUserTaggingTextStorageState)
{
    VUserTaggingTextStorageStateInactive,
    VUserTaggingTextStorageStateTriggerCharacterDetected,
    VUserTaggingTextStorageStateSearchActive
};

static NSString * const kTriggerCharacter = @"@";

@interface VUserTaggingTextStorage ()

@property (nonatomic, strong) NSMutableAttributedString *innerStorage;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSRange searchTermRange; ///< This range includes the trigger character

@end

@implementation VUserTaggingTextStorage

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _innerStorage = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (void)setState:(NSInteger)state
{
    if ( state == _state )
    {
        return;
    }
    VLog(@"new state: %ld", (long)state);
    _state = state;
}

#pragma mark - NSAttributedString primatives

- (NSString *)string
{
    return self.innerStorage.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.innerStorage attributesAtIndex:location effectiveRange:range];
}

#pragma mark - NSMutableAttributedString primatives

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self.innerStorage replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(str.length - range.length)];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self.innerStorage setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
