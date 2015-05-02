//
//  VPermissions.h
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

@interface VPermissions : NSObject

+ (VPermissions *)permissionsWithNumber:(NSNumber *)numberValue;

- (instancetype)initWithNumber:(NSNumber *)numberValue;

@property (nonatomic, readonly) BOOL canDelete;
@property (nonatomic, readonly) BOOL canRemix;
@property (nonatomic, readonly) BOOL canVote;
@property (nonatomic, readonly) BOOL canComment;
@property (nonatomic, readonly) BOOL canShowVoteCount;
@property (nonatomic, readonly) BOOL canRepost;
@property (nonatomic, readonly) BOOL canMeme;
@property (nonatomic, readonly) BOOL canGIF;
@property (nonatomic, readonly) BOOL canShare;

@end
