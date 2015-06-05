//
//  VSequencePermissions.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePermissions.h"

typedef NS_OPTIONS(NSInteger, VSequencePermission)
{
    VSequencePermissionNone             = 0,
    VSequencePermissionCanDelete        = 1 << 0,
    VSequencePermissionCanRemix         = 1 << 1,
    VSequencePermissionCanShowVoteCount = 1 << 2,
    VSequencePermissionCanComment       = 1 << 3,
    VSequencePermissionCanRepost        = 1 << 4,
    VSequencePermissionCanEditComment   = 1 << 5,
    VSequencePermissionCanDeleteComment = 1 << 6,
    VSequencePermissionCanFlagSequence  = 1 << 7,
    VSequencePermissionCanMeme          = 1 << 8,
    VSequencePermissionCanGif           = 1 << 9,
    VSequencePermissionCanQuote         = 1 << 10,
};

@interface VSequencePermissions()

@property (nonatomic, readonly) NSInteger integerValue;

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
        _integerValue = numberValue.integerValue;
    }
    return self;
}

- (BOOL)canDelete
{
    return self.integerValue & VSequencePermissionCanDelete;
}

- (BOOL)canRemix
{
    return self.integerValue & VSequencePermissionCanRemix;
}

- (BOOL)canComment
{
    return self.integerValue & VSequencePermissionCanComment;
}

- (BOOL)canRepost
{
    return self.integerValue & VSequencePermissionCanRepost;
}

- (BOOL)canShowVoteCount
{
    return self.integerValue & VSequencePermissionCanShowVoteCount;
}

- (BOOL)canMeme
{
    return self.integerValue & VSequencePermissionCanMeme;
}

- (BOOL)canGIF
{
    return self.integerValue & VSequencePermissionCanGif;
}

- (BOOL)canQuote
{
    return self.integerValue & VSequencePermissionCanQuote;
}

@end
