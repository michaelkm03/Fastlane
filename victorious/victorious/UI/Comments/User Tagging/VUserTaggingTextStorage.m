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
static NSString * const kThreeSpaces = @"   ";

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

- (void)setSearchTermRange:(NSRange)searchTermRange
{
    _searchTermRange = searchTermRange;
    VLog(@"search term: %@", [self.innerStorage.string substringWithRange:searchTermRange]);
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

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string
{
    [self.innerStorage replaceCharactersInRange:range withString:string];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(string.length - range.length)];
    
    switch (self.state)
    {
        case VUserTaggingTextStorageStateInactive:
        {
            if ( [string isEqualToString:kTriggerCharacter] )
            {
                self.state = VUserTaggingTextStorageStateTriggerCharacterDetected;
                self.searchTermRange = NSMakeRange(range.location, kTriggerCharacter.length);
            }
            break;
        }
        case VUserTaggingTextStorageStateTriggerCharacterDetected:
        {
            if ( string.length != 1 || ![[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:0]] )
            {
                self.state = VUserTaggingTextStorageStateInactive;
                break;
            }
            // fall-through on purpose!
        }
        case VUserTaggingTextStorageStateSearchActive:
        {
            if ( !NSLocationInRange(range.location, NSMakeRange(self.searchTermRange.location + 1, self.searchTermRange.length + 1)) ) // Check to see if the insertion point changed. We consider that a cancellation of search.
            {
                self.state = VUserTaggingTextStorageStateInactive;
            }
            else
            {
                self.searchTermRange = NSMakeRange(self.searchTermRange.location, self.searchTermRange.length + string.length - range.length);

                if ( self.searchTermRange.length >= 3 )
                {
                    NSRange rangeOfLastThreeCharacters = NSMakeRange(self.searchTermRange.location + self.searchTermRange.length - 3, 3);
                    NSString *lastThreeCharacters = [self.innerStorage.string substringWithRange:rangeOfLastThreeCharacters];
                    
                    if ( [lastThreeCharacters isEqualToString:kThreeSpaces] )
                    {
                        self.state = VUserTaggingTextStorageStateInactive;
                        break;
                    }
                }
                self.state = VUserTaggingTextStorageStateSearchActive;
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self.innerStorage setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
