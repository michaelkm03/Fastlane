//
//  VPermissions.m
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissions.h"

typedef NS_OPTIONS(NSInteger, VPermission)
{
    VPermissionNone             = 0,
    VPermissionCanDelete        = 1 << 0,
    VPermissionCanRemix         = 1 << 1,
    VPermissionCanShowVoteCount = 1 << 2,
    VPermissionCanComment       = 1 << 3,
    VPermissionCanRepost        = 1 << 4,
    VPermissionCanEditComment   = 1 << 5,
    VPermissionCanDeletecomment = 1 << 6,
    VPermissionCanFlagSequence  = 1 << 7,
    VPermissionCanMeme          = 1 << 8,
    VPermissionCanGif           = 1 << 9,
    VPermissionCanShare         = 1 << 9,
};

@interface VPermissions()

@property (nonatomic, readonly) NSInteger integerValue;

@end

@implementation VPermissions

+ (VPermissions *)permissionsWithNumber:(NSNumber *)numberValue
{
    return [[VPermissions alloc] initWithNumber:numberValue];
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
    return self.integerValue & VPermissionCanDelete;
}

- (BOOL)canRemix
{
    return self.integerValue & VPermissionCanRemix;
}

- (BOOL)canVote
{
    return self.integerValue & VPermissionCanDelete;
}

- (BOOL)canComment
{
    return self.integerValue & VPermissionCanComment;
}

- (BOOL)canRepost
{
    return self.integerValue & VPermissionCanRepost;
}

- (BOOL)canShowVoteCount
{
    return self.integerValue & VPermissionCanShowVoteCount;
}

- (BOOL)canMeme
{
    return self.integerValue & VPermissionCanMeme;
}

- (BOOL)canGIF
{
    return self.integerValue & VPermissionCanGif;
}

- (BOOL)canShare
{
    return self.integerValue & VPermissionCanShare;
}

@end
