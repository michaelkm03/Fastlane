//
//  VSequencePermissions.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePermissions.h"

/**
 Values corresponding to permissions bitmask returned by server.
 */
typedef NS_OPTIONS( NSInteger, VSequencePermission )
{
    VSequencePermissionNone                 = 0,
    VSequencePermissionCanDelete            = 1 << 0,
    VSequencePermissionCanRemix             = 1 << 1,
    VSequencePermissionCanShowVoteCount     = 1 << 2,
    VSequencePermissionCanComment           = 1 << 3,
    VSequencePermissionCanRepost            = 1 << 4,
    VSequencePermissionCanEditComments      = 1 << 5,
    VSequencePermissionCanDeleteComments    = 1 << 6,
    VSequencePermissionCanFlagSequence      = 1 << 7,
    VSequencePermissionCanMeme              = 1 << 8,
    VSequencePermissionCanGif               = 1 << 9,
    VSequencePermissionCanQuote             = 1 << 10,
};

@interface VSequencePermissions()

@property (nonatomic, readonly) NSUInteger value;

@end

@implementation VSequencePermissions

+ (VSequencePermissions *)permissionsWithNumber:(NSNumber *)numberValue
{
    return [[VSequencePermissions alloc] initWithNumber:numberValue];
}

- (instancetype)init
{
    return [self initWithNumber:nil];
}

- (instancetype)initWithNumber:(NSNumber *)numberValue
{
    NSParameterAssert( numberValue != nil );
    
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

- (BOOL)canDeleteComments
{
    return self.value & VSequencePermissionCanDeleteComments;
}

- (BOOL)canShowVoteCount
{
    return self.value & VSequencePermissionCanShowVoteCount;
}

- (BOOL)canFlagSequence
{
    return self.value & VSequencePermissionCanFlagSequence;
}

- (BOOL)canEditComments
{
    return self.value & VSequencePermissionCanEditComments;
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