//
//  VCapitalizingTextStorage.m
//  victorious
//
//  Created by Michael Sena on 12/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCapitalizingTextStorage.h"

@interface VCapitalizingTextStorage ()

@property (nonatomic, strong, readwrite) NSMutableAttributedString *enteredText;
@property (nonatomic, strong) NSMutableAttributedString *capitalizedText;

@end

@implementation VCapitalizingTextStorage

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _enteredText = [[NSMutableAttributedString alloc] init];
        _capitalizedText = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

#pragma mark - Required Overrides

- (NSString *)string
{
    [self ensureAttributesAreFixedInRange:NSMakeRange(0, [self v_activeInternalString].string.length)];
    return [self v_activeInternalString].string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    [self ensureAttributesAreFixedInRange:NSMakeRange(0, [self v_activeInternalString].string.length)];
    return [[self v_activeInternalString] attributesAtIndex:location
                                      longestEffectiveRange:range
                                                    inRange:NSMakeRange(0, self.string.length)];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self.enteredText replaceCharactersInRange:range
                                    withString:str];
    [self.capitalizedText replaceCharactersInRange:range
                                        withString:str];
    [self edited:NSTextStorageEditedCharacters
           range:range
  changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self.enteredText setAttributes:attrs
                              range:range];
    [self.capitalizedText setAttributes:attrs
                                  range:range];
    [self edited:NSTextStorageEditedAttributes
           range:range
  changeInLength:0];
}

#pragma mark - Other overrides

- (void)processEditing
{
    [self.capitalizedText replaceCharactersInRange:NSMakeRange(0, self.capitalizedText.string.length)
                                        withString:[self.capitalizedText.string uppercaseString]];

    [super processEditing];
}

#pragma mark - Property Accessors

- (void)setShouldForceUppercase:(BOOL)shouldForceUppercase
{
    if (_shouldForceUppercase == shouldForceUppercase)
    {
        return;
    }
    _shouldForceUppercase = shouldForceUppercase;
}

#pragma mark - Internal Methods

- (NSMutableAttributedString *)v_activeInternalString
{
    return self.shouldForceUppercase ? self.capitalizedText : self.enteredText;
}

@end
