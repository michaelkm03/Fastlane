//
//  VComment+Fetcher.h
//  victorious
//
//  Created by Will Long on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComment.h"

@interface VComment (Fetcher)

- (BOOL)hasMedia;
- (NSURL *)previewImageURL;

@property (nonatomic, assign, readonly) BOOL isEditable;
@property (nonatomic, assign, readonly) BOOL isDeletable;
@property (nonatomic, assign, readonly) BOOL isFlaggable;

@end
