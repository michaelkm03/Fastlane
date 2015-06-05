//
//  VSequencePermissions.h
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

typedef NS_OPTIONS( NSInteger, VSequencePermission)
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

@interface VSequencePermissions : NSObject

+ (VSequencePermissions *)permissionsWithNumber:(NSNumber *)numberValue;

- (instancetype)initWithNumber:(NSNumber *)numberValue;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRemix;
@property (nonatomic, readonly) BOOL canShowVoteCount;
@property (nonatomic, readonly) BOOL canRepost;
@property (nonatomic, readonly) BOOL canComment;
@property (nonatomic, readonly) BOOL canEditComment;
@property (nonatomic, readonly) BOOL canDeleteComment;
@property (nonatomic, readonly) BOOL canFlagSequence;
@property (nonatomic, readonly) BOOL canMeme;
@property (nonatomic, readonly) BOOL canGIF;
@property (nonatomic, readonly) BOOL canQuote;

@end
