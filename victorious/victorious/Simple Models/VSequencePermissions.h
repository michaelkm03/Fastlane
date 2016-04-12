//
//  VSequencePermissions.h
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 Wrapper for a permissions bitmask that exposes boolean properties for
 more concise and easily readable code when read.
 */
@interface VSequencePermissions : NSObject

/**
 Convenience initializer that internally calls `initWithNumber:`
 */
+ (VSequencePermissions *)permissionsWithNumber:(NSNumber *)numberValue;

/**
 Designated initializer with required raw bit mark value as NSNumber.
 */
- (instancetype)initWithNumber:(NSNumber *)numberValue NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRemix;
@property (nonatomic, readonly) BOOL canShowVoteCount;
@property (nonatomic, readonly) BOOL canRepost;
@property (nonatomic, readonly) BOOL canComment;
@property (nonatomic, readonly) BOOL canEditComments;
@property (nonatomic, readonly) BOOL canDeleteComments;
@property (nonatomic, readonly) BOOL canFlagSequence;
@property (nonatomic, readonly) BOOL canMeme;
@property (nonatomic, readonly) BOOL canAddGifComments;

@end
