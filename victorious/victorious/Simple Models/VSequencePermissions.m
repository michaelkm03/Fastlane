//
//  VSequencePermissions.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePermissions.h"
#import "NSNumber+VBitmask.h"

/**
 Values corresponding to permissions bitmask returned by server.
 */
typedef NS_OPTIONS( NSUInteger, VSequencePermission )
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
    VSequencePermissionCanMeme              = 1 << 9,
    VSequencePermissionCanQuote             = 1 << 10,
    VSequencePermissionCanAddGifComments    = 1 << 11
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
    if ( numberValue == nil )
    {
        return nil;
    }
    
    self = [super init];
    if ( self != nil )
    {
        _value = numberValue.unsignedIntegerValue;
    }
    return self;
}

- (BOOL)canDelete
{
    return (self.value & VSequencePermissionCanDelete) != 0ul;
}

- (BOOL)canRemix
{
    return (self.value & VSequencePermissionCanRemix) != 0ul;
}

- (BOOL)canComment
{
    return (self.value & VSequencePermissionCanComment) != 0ul;
}

- (BOOL)canRepost
{
    return (self.value & VSequencePermissionCanRepost) != 0ul;
}

- (BOOL)canDeleteComments
{
    return (self.value & VSequencePermissionCanDeleteComments) != 0ul;
}

- (BOOL)canShowVoteCount
{
    return (self.value & VSequencePermissionCanShowVoteCount) != 0ul;
}

- (BOOL)canFlagSequence
{
    return (self.value & VSequencePermissionCanFlagSequence) != 0ul;
}

- (BOOL)canEditComments
{
    return (self.value & VSequencePermissionCanEditComments) != 0ul;
}

- (BOOL)canMeme
{
    return (self.value & VSequencePermissionCanMeme) != 0ul;
}

- (BOOL)canQuote
{
    return (self.value & VSequencePermissionCanQuote) != 0ul;
}

- (BOOL)canAddGifComments
{
    return (self.value & VSequencePermissionCanAddGifComments) != 0ul;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"VSequencePermissions = %@", [NSNumber v_bitmaskString:self.value]];
}

@end
