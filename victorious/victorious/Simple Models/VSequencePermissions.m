//
//  VSequencePermissions.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePermissions.h"

@interface VSequencePermissions()

@property (nonatomic, readonly) NSUInteger value;

@end

@implementation VSequencePermissions

+ (VSequencePermissions *)permissionsWithNumber:(NSNumber *)numberValue
{
    return [[VSequencePermissions alloc] initWithNumber:numberValue];
}

- (instancetype)initWithNumber:(NSNumber *)numberValue
{
    self = [super init];
    if ( self != nil )
    {
        _value = numberValue.unsignedIntegerValue;
    }
    return self;
}

- (BOOL)canDelete
{
    return self.value & VSequencePermissionCanDelete;
}

- (BOOL)canRemix
{
    return self.value & VSequencePermissionCanRemix;
}

- (BOOL)canComment
{
    return self.value & VSequencePermissionCanComment;
}

- (BOOL)canRepost
{
    return self.value & VSequencePermissionCanRepost;
}

- (BOOL)canDeleteComment
{
    return self.value & VSequencePermissionCanDeleteComment;
}

- (BOOL)canFlagSequence
{
    return self.value & VSequencePermissionCanFlagSequence;
}

- (BOOL)canEditComment
{
    return self.value & VSequencePermissionCanEditComment;
}

- (BOOL)canMeme
{
    return self.value & VSequencePermissionCanMeme;
}

- (BOOL)canGIF
{
    return self.value & VSequencePermissionCanGif;
}

- (BOOL)canQuote
{
    return self.value & VSequencePermissionCanQuote;
}

- (NSString *)description
{
    NSMutableString *stringBits = [[NSMutableString alloc] init];
    NSUInteger spacing = pow( 2, 3 );
    NSUInteger width = ( sizeof( self.value ) ) * spacing;
    NSUInteger binaryDigit = 0;
    NSUInteger integer = self.value;
    
    while ( binaryDigit < width )
    {
        binaryDigit++;
        [stringBits insertString:( (integer & 1) ? @"1" : @"0" )atIndex:0];
        if ( binaryDigit % spacing == 0 && binaryDigit != width )
        {
            [stringBits insertString:@" " atIndex:0];
        }
        integer = integer >> 1;
    }
    
    return [NSString stringWithFormat:@"VSequencePermissions = %@", stringBits];
}

@end
